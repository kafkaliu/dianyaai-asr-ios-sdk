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

本 SDK 提供两个主要的客户端用于语音识别：`RealTimeTranscribeClient` 用于实时音频流，`FileTranscribeClient` 用于转写预先录制的音频文件。

### 实时转写

使用 `RealTimeTranscribeClient` 从连续的音频流（例如麦克风）中获取转写结果。该客户端使用现代 Swift 并发模型构建，并通过 WebSocket 进行通信。

**音频格式:** 客户端期望的音频数据格式为 **16kHz 采样率、16位深度、单声道 PCM**。

**示例:**

```swift
import DianyaaiASR
import Foundation

// 1. 初始化实时客户端。
// 客户端是一个 actor，因此所有与其的交互都必须使用 `await`。
let client = createRealTimeTranscribeClient(authToken: "YOUR_AUTH_TOKEN")

// 2. 设置任务以监听状态和数据流。
// 在调用 connect() 之前开始监听是至关重要的。

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
    for await message in client.dataStream {
        switch message.data {
        case .asrResult(let result):
            print("最终结果: \(result.text)")
        case .asrResultPartial(let result):
            print("部分结果: \(result.text)")
        case .error(let serverError):
            print("服务器错误: \(serverError.data)")
        case .stop:
            print("服务器已表示转写结束。")
            // 此消息后，dataStream 将会结束。
        }
    }
    print("数据流已结束。")
}

// 3. 连接到服务器。
await client.connect()

// 4. 发送音频数据。
// 在真实的应用中，您会从麦克风管理器获取这些数据。
// 客户端会自动缓冲并以正确大小的块发送数据。
// 音频必须是 16kHz、16位、单声道 PCM 格式。
await client.sendAudioChunk(someAudioData)

// 5. 表示音频发送结束。
// 当您完成发送音频后，调用 `stopSendingAudio()`。
// 客户端会发送所有剩余的缓冲音频，然后向服务器发送一个特殊的
// “结束”消息。连接将保持打开以接收任何最终结果。
await client.stopSendingAudio()

// 6. 断开连接。
// 当您完全完成并希望关闭连接时，调用 `disconnect()`。
// 这将关闭 WebSocket 并释放资源。
await client.disconnect()
```

### 文件转写

使用 `FileTranscribeClient` 来转写一个本地音频文件。客户端会处理文件上传和状态轮询。

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

// 3. 监听来自流的状态变化和数据更新。
Task {
    for await state in client.stateStream {
        print("客户端状态改变: \(state)")
        if case .failed(let error) = state {
            print("客户端因错误失败: \(error.localizedDescription)")
        }
    }
}

Task {
    for await message in client.dataStream {
        print("收到状态: \(message.data.description)")
        
        // 检查转写是否完成
        if message.data == .done {
            print("转写完成！")
            if let summary = message.summaryMd {
                print("--- 总结 ---")
                print(summary)
            }
            if let details = message.details {
                 print("--- 详情 ---")
                for detail in details {
                    print("说话人 \(detail.speaker) (\(detail.startTime)-\(detail.endTime)s): \(detail.text)")
                }
            }
            // 此消息后，dataStream 将会结束。
        } else if message.data.isFailed {
            print("转写失败，状态为: \(message.status)")
        }
    }
    print("数据流已结束。")
}

// 4. 启动转写流程。
await client.start()
```

