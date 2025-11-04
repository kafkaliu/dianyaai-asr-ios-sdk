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

要转写一个音频文件，您需要使用您的身份验证令牌初始化 `DianyaaiASRAPI`，然后调用 `transcribeFile` 方法。

```swift
import DianyaaiASR
import Foundation

// 1. 使用您的身份验证令牌配置 SDK。
let configuration = DianyaaiASRConfiguration(authToken: "YOUR_AUTH_TOKEN")

// 2. 初始化 API 客户端。
let api = DianyaaiASRAPI(configuration: configuration)

// 3. 获取您要转写的音频文件的 URL。
guard let fileURL = Bundle.main.url(forResource: "myaudio", withExtension: "mp3") else {
    print("找不到音频文件。")
    return
}

// 4. 转写文件。
Task {
    do {
        let transcriptionStatus = try await api.transcribeFile(fileURL: fileURL)
        
        // 5. 处理转写结果。
        if transcriptionStatus.status == "done" {
            if let details = transcriptionStatus.details {
                for detail in details {
                    print("说话人 \(detail.speaker): \(detail.text) (\(detail.startTime)s - \(detail.endTime)s)")
                }
            }
        } else {
            print("转写失败，状态: \(transcriptionStatus.status)")
        }
    } catch {
        print("发生错误: \(error)")
    }
}
```

### 错误处理

`transcribeFile` 方法可能会抛出错误。您应该将调用包装在 `do-catch` 块中以处理潜在的错误，例如网络问题或 API 错误。

### 实时转写

本 SDK 为来自连续音频流（例如来自麦克风）的实时转写提供了一个强大而灵活的 API。

该 API 围绕现代 Swift 并发模型设计。您提供一个音频数据流，作为回报，您会得到一个控制器对象，该对象可让您管理转写生命周期（`start`、`pause`、`resume`、`stop`）和一个转写结果流。

**示例：**

```swift
import DianyaaiASR
import Foundation

// 1. 配置并初始化 API 客户端。
let configuration = DianyaaiASRConfiguration(authToken: "YOUR_AUTH_TOKEN")
let api = DianyaaiASRAPI(configuration: configuration)

// 2. 创建一个 `AsyncStream` 作为您的音频源。
//    在真实的应用中，您会从一个麦克风管理器获取这个流。
let (audioStream, audioContinuation) = AsyncStream.makeStream(of: Data.self)

// 3. 通过提供音频源来获取转写控制器。
let controller = api.transcribeStream(audioSource: audioStream)

// 4. 启动一个任务来监听转写结果。
Task {
    for await result in controller.results {
        switch result {
        case .asrResult(let data), .asrResultPartial(let data):
            print("收到文本: \(data.text)")
        case .error(let error):
            print("收到错误: \(error)")
        case .stop:
            print("服务器已表示转写结束。")
        }
    }
    print("结果流已结束。")
}

// 5. 现在您可以完全控制生命周期。

// 开始转写。它将开始处理来自流的音频。
controller.start()

// 将音频数据推入流中。
// (在真实的应用中，您的麦克风管理器会做这件事。)
// audioContinuation.yield(someAudioDataChunk)
// audioContinuation.yield(anotherAudioDataChunk)

// 暂停转写。暂停期间发送的音频块将被忽略。
controller.pause()

// 恢复转写。它将从流的当前位置开始处理音频。
controller.resume()

// 推送更多音频数据。
// audioContinuation.yield(moreAudioData)

// 当您完全完成时，停止控制器。
// 这将终止连接并释放所有资源。
controller.stop()

// 在音频源耗尽时，完成音频流的 continuation 也是一个好习惯。
audioContinuation.finish()
```
