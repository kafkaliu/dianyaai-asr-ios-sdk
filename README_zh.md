# DianyaaiASR iOS SDK

DianyaaiASR 是一个 iOS SDK，用于将电牙 AI 的自动语音识别（ASR）服务集成到您的 iOS 应用程序中。

## 功能

- 文件转写：转写音频文件并获取结果。
- 来自连续音频流的实时转写。

## 安装

本项目是一个 Swift Package。您可以按照以下步骤将其添加到您的 Xcode 项目中：

1. 在 Xcode 中，转到 **File > Add Packages...**。
2. 在 “Search or Enter Package URL” 字段中，输入此存储库的 URL。
3. 单击 **Add Package**。

## 使用方法

### 文件转写

要转写一个音频文件，您需要创建一个 `FileTranscribeClient` 并调用 `start` 方法。该客户端提供两个流：`stateStream` 用于监控客户端的状态，`statusStream` 用于接收转写状态更新。

**示例:**

```swift
import DianyaaiASR
import Foundation

// 1. 获取您要转写的音频文件的 URL。
guard let fileURL = Bundle.main.url(forResource: "myaudio", withExtension: "mp3") else {
    print("找不到音频文件。")
    return
}

// 2. 创建文件转写客户端。
let client = createFileTranscribeClient(authToken: "YOUR_AUTH_TOKEN", fileURL: fileURL)

// 3. 监听来自流的状态变化和状态更新。
Task {
    for await state in client.stateStream {
        print("客户端状态改变: \(state)")
        if case .failed(let error) = state {
            print("客户端因错误失败: \(error.localizedDescription)")
        }
    }
}

Task {
    for await status in client.statusStream {
        print("收到状态: \(status.status)")
        if status.status == "done" {
            if let details = status.details {
                for detail in details {
                    print("说话人 \(detail.speaker): \(detail.text)")
                }
            }
        }
    }
    print("状态流已结束。")
}

// 4. 启动转写流程。
await client.start()
```

### 实时转写

本 SDK 提供了一个 `RealTimeTranscribeClient`，用于从连续的音频流（例如来自麦克风）进行实时转写。该客户端使用现代 Swift 并发模型（async/await）构建，并通过 WebSocket 进行通信。

**主要特性:**

-   **状态管理:** 客户端通过 `stateStream` (`AsyncStream<ClientState>`) 暴露其连接状态（例如 `.connecting`, `.connected`, `.reconnecting`, `.stopped`）。
-   **结果流:** 转写结果通过 `messageStream` (`AsyncStream<ServerMessage>`) 传递，提供强类型的事件，如 `.asrResult` (最终结果), `.asrResultPartial` (中间结果), 和 `.error`。
-   **自动重连:** 客户端采用指数退避策略自动处理意外断开连接。
-   **线程安全:** 客户端是一个 `actor`，确保其所有方法和属性都可以从任何线程安全地访问。

**示例:**

```swift
import DianyaaiASR
import Foundation

// 1. 初始化实时客户端。
//    客户端是一个 actor，因此所有与其的交互都必须使用 `await`。
let client = createRealTimeTranscribeClient(authToken: "YOUR_AUTH_TOKEN")

// 2. 设置任务以监听状态和消息流。
//    在调用 connect() 之前开始监听是至关重要的。

// 监听连接状态变化
Task {
    for await state in client.stateStream {
        print("客户端状态改变: \(state)")
        if case .stopped(let error) = state {
            if let error = error {
                print("客户端因错误停止: \(error.localizedDescription)")
            } else {
                print("客户端已正常停止。")
            }
        }
    }
}

// 监听来自服务器的转写消息
Task {
    for await message in client.messageStream {
        switch message {
        case .asrResult(let result):
            print("最终结果: \(result.text)")
        case .asrResultPartial(let result):
            print("部分结果: \(result.text)")
        case .error(let serverError):
            print("服务器错误: \(serverError.data)")
        case .stop:
            print("服务器已表示转写结束。")
        }
    }
    print("消息流已结束。")
}

// 3. 连接到服务器。
await client.connect()

// 4. 发送音频数据。
//    在真实的应用中，您会从麦克风管理器获取这些数据。
//    客户端会缓冲数据并以正确的大小分块发送。
//    您可以从任何线程调用 `sendAudioChunk`。
//
//    client.sendAudioChunk(someAudioData)

// 5. 表示音频结束。
//    当您完成发送音频后，调用 `stopSendingAudio()`。
//    客户端将发送所有剩余的缓冲音频，然后向服务器发送一个特殊的
//    “结束”消息。连接将保持打开以接收任何最终结果。
await client.stopSendingAudio()

// 6. 断开连接。
//    当您完全完成并希望关闭连接时，调用 `disconnect()`。
//    这将关闭 WebSocket 并释放资源。
await client.disconnect()
```
