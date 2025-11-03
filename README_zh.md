# DianyaaiASR iOS SDK

DianyaaiASR 是一个 iOS SDK，用于将电牙 AI 的自动语音识别（ASR）服务集成到您的 iOS 应用程序中。

## 功能

- 文件转写：转写音频文件并获取结果。
- 实时转写（即将推出）。

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
