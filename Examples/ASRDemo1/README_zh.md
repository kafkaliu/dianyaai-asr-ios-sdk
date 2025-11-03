# ASRDemo1: DianyaaiASR iOS SDK 示例

该项目是一个简单的示例，演示了如何使用 [DianyaaiASR iOS SDK](https://github.com/dianyaai/dianyaai-asr-ios-sdk) 进行音频转写。

## 主要功能

- 从您的设备中选择一个音频文件。
- 使用 DianyaaiASR SDK 转写音频文件。
- 显示转写结果。
- 配置认证令牌（`authToken`）。

## 如何使用

1.  **克隆代码库：**
    ```bash
    git clone https://github.com/kafkaliu/dianyaai-asr-ios-sdk.git
    cd dianyaai-asr-ios-sdk/Examples/ASRDemo1
    ```

2.  **在 Xcode 中打开项目：**
    ```bash
    open ASRDemo1.xcodeproj
    ```

3.  **配置认证令牌：**
    - 在模拟器或真实设备上运行 App。
    - 点击齿轮图标进入设置页面。
    - 输入您的 `authToken`。您可以从 [点呀AI](https://www.dianyaai.com) 获取令牌。
    - 点击“保存”。

4.  **转写音频文件：**
    - 返回主屏幕。
    - 点击文档图标打开文件选择器。
    - 选择一个音频文件。
    - App 将开始转写，您将在屏幕上看到结果。

## 代码集成

该示例演示了 DianyaaiASR SDK 的基本集成方法。以下是代码中的关键部分：

### `ASRViewModel.swift`

该文件包含了与 DianyaaiASR SDK 交互的核心逻辑。

1.  **初始化：**
    在 `setup()` 方法中，我们使用认证令牌初始化 `DianyaaiASRAPI`。

    ```swift
    import DianyaaiASR

    // ...

    func setup() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        let config = DianyaaiASR.DianyaaiASRConfiguration(authToken: self.authToken)
        self.asrApi = DianyaaiASRAPI(configuration: config)
    }
    ```

2.  **转写：**
    `transcribeFile(url:)` 方法调用 SDK 的 `transcribeFile` 方法来执行转写。

    ```swift
    func transcribeFile(url: URL) {
        isTranscribing = true
        Task {
            do {
                if let status = try await asrApi?.transcribeFile(fileURL: url) {
                    if status.status == "done" {
                        self.transcriptionStatus = status
                    } else {
                        self.transcriptionResult = "转写失败: \(status.message ?? "未知错误")"
                    }
                }
            } catch {
                self.transcriptionResult = "转写失败: \(error.localizedDescription)"
            }
            isTranscribing = false
        }
    }
    ```

### `ASRView.swift`

这个 SwiftUI 视图提供了文件选择和结果显示的用户界面。它使用 `.fileImporter` 来让用户选择音频文件。

```swift
.fileImporter(isPresented: $isShowingFilePicker, allowedContentTypes: [.audio]) { result in
    switch result {
    case .success(let url):
        viewModel.transcribeFile(url: url)
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```
