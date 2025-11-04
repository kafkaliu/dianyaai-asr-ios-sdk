# ASRDemo2: DianyaaiASR iOS SDK 实时转录示例

本项目是一个简单的演示，展示了如何使用 [DianyaaiASR iOS SDK](https://github.com/kafkaliu/dianyaai-asr-ios-sdk) 进行麦克风实时音频转录。

## 功能

- 从麦克风进行实时音频转录。
- 在转录过程中实时显示转录结果。
- 配置认证令牌。
- 暂停和恢复转录。

## 如何使用

1.  **克隆仓库：**
    ```bash
    git clone https://github.com/kafkaliu/dianyaai-asr-ios-sdk.git
    cd dianyaai-asr-ios-sdk/Examples/ASRDemo2
    ```

2.  **在 Xcode 中打开项目：**
    ```bash
    open ASRDemo2.xcodeproj
    ```

3.  **配置认证令牌：**
    - 在模拟器或真实设备上运行应用。
    - 点击齿轮图标进入设置界面。
    - 输入您的 `authToken`。您可以从 [Dianyaai](https://www.dianyaai.com) 获取令牌。
    - 点击“保存”。

4.  **转录音频文件：**
    - 返回主屏幕。
    - 点击“开始转录”以开始从麦克风录音。
    - 应用将开始转录，您将在屏幕上实时看到结果。
    - 点击“暂停转录”以暂停录音。
    - 点击“恢复转录”以继续。
    - 点击“停止转录”以结束转录会话。

## 代码集成

本示例演示了 DianyaaiASR SDK 进行实时转录的基本集成。以下是代码中的关键部分：

### `MicrophoneManager.swift`

该文件负责从麦克风捕获音频，并将其作为 `AsyncStream<Data>` 提供。它还处理将音频格式转换为 ASR 服务所需的格式（16kHz、16位 PCM、单声道）。

### `ASRViewModel.swift`

该文件包含与 DianyaaiASR SDK 交互的核心逻辑。

1.  **初始化：**
    在 `init()` 方法中，我们使用认证令牌设置 `DianyaaiASRAPI`，并绑定到 `MicrophoneManager` 的错误消息。

    ```swift
    import DianyaaiASR

    // ...

    init() {
        setupAuthToken()
        setupMicrophoneManagerBindings()
    }

    private func setupAuthToken() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        updateASRAPI()
    }

    private func updateASRAPI() {
        let config = DianyaaiASR.DianyaaiASRConfiguration(authToken: self.authToken)
        self.asrApi = DianyaaiASRAPI(configuration: config)
    }
    ```

2.  **实时转录：**
    `startTranscription()` 方法启动麦克风录音，并启动实时转录流。它使用 SDK 的 `transcribeStream` 方法，提供来自 `MicrophoneManager` 的音频流。然后，它观察来自 `asrStreamController` 的结果。

    ```swift
    func startTranscription() {
        // ...
        Task {
            do {
                // 启动麦克风录音
                await microphoneManager.startRecording()

                // 初始化 ASR 流控制器
                self.asrStreamController = asrApi.transcribeStream(audioSource: microphoneManager.sharedAudioStream)

                // 观察转录结果
                resultsTask = Task {
                    for await result in self.asrStreamController!.results {
                        // ... 处理结果
                    }
                }

                // 启动 ASR 流
                asrStreamController?.start()
            } catch {
                // ... 处理错误
            }
        }
    }
    ```

### `ASRView.swift`

此 SwiftUI 视图提供了用于开始、停止和暂停转录以及显示实时转录结果的用户界面。
