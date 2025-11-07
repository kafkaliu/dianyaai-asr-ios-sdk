# ASRDemo1: DianyaaiASR iOS SDK Example

This project is a simple demonstration of how to use the [DianyaaiASR iOS SDK](https://github.com/dianyaai/dianyaai-asr-ios-sdk) for audio transcription.

## Features

- Select an audio file from your device.
- Transcribe the audio file using the DianyaaiASR SDK.
- Display the transcription result.
- Configure the authentication token.

## How to Use

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/kafkaliu/dianyaai-asr-ios-sdk.git
    cd dianyaai-asr-ios-sdk/Examples/ASRDemo1
    ```

2.  **Open the project in Xcode:**
    ```bash
    open ASRDemo1.xcodeproj
    ```

3.  **Configure Authentication Token:**
    - Run the app on a simulator or a real device.
    - Navigate to the settings screen by tapping the gear icon.
    - Enter your `authToken`. You can obtain a token from [Dianyaai](https://www.dianyaai.com).
    - Tap "Save".

4.  **Transcribe an Audio File:**
    - Go back to the main screen.
    - Tap the document icon to open the file picker.
    - Select an audio file.
    - The app will start the transcription, and you will see the result on the screen.

## Code Integration

This example demonstrates the basic integration of the DianyaaiASR SDK. Here are the key parts in the code:

### `ASRViewModel.swift`

This file contains the core logic for interacting with the DianyaaiASR SDK.

1.  **Initialization:**
    In the `setup()` method, we initialize the `DianyaaiASRAPI` with the authentication token.

    ```swift
    import DianyaaiASR

    // ...

    func setup() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        let config = DianyaaiASR.DianyaaiASRConfiguration(authToken: self.authToken)
        self.asrApi = DianyaaiASRAPI(configuration: config)
    }
    ```

2.  **Transcription:**
    The `transcribeFile(url:)` method calls the `transcribeFile` method of the SDK. This method now returns a `controller` and a `dataStream`. The `controller` is used to start the transcription, and the `dataStream` provides real-time status updates.

    ```swift
    func transcribeFile(url: URL) {
        isTranscribing = true
        transcriptionStatus = nil
        transcriptionResult = "Transcribing..."

        let asrApi = DianyaaiASRAPI(configuration: DianyaaiASRConfiguration(authToken: self.authToken))
        let (controller, dataStream) = asrApi.transcribeFile(fileURL: url)
        Task {
            for await status in dataStream {
                if status.type == .done {
                    self.transcriptionStatus = status
                } else if status.type.isFailed {
                    self.transcriptionResult = "Transcription failed: \(status.message ?? "Unknown error")"
                }
            }
            isTranscribing = false
        }
        controller.start()
    }
    ```

### `ASRView.swift`

This SwiftUI view provides the user interface for file selection and displaying the result. It uses the `.fileImporter` to allow users to pick an audio file.

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

### `TranscriptionResultView.swift`

This view is responsible for displaying the final transcription result in a structured and user-friendly format. It shows the transcribed text and other relevant information from the `TranscriptionStatus` object.
```
