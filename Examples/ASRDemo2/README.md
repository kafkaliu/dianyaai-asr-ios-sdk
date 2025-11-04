# ASRDemo2: DianyaaiASR iOS SDK Real-Time Transcription Example

This project is a simple demonstration of how to use the [DianyaaiASR iOS SDK](https://github.com/kafkaliu/dianyaai-asr-ios-sdk) for real-time audio transcription from the microphone.

## Features

- Real-time transcription from the microphone.
- Display the transcription result as it is being transcribed.
- Configure the authentication token.
- Pause and resume transcription.

## How to Use

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/kafkaliu/dianyaai-asr-ios-sdk.git
    cd dianyaai-asr-ios-sdk/Examples/ASRDemo2
    ```

2.  **Open the project in Xcode:**
    ```bash
    open ASRDemo2.xcodeproj
    ```

3.  **Configure Authentication Token:**
    - Run the app on a simulator or a real device.
    - Navigate to the settings screen by tapping the gear icon.
    - Enter your `authToken`. You can obtain a token from [Dianyaai](https://www.dianyaai.com).
    - Tap "Save".

4.  **Transcribe an Audio File:**
    - Go back to the main screen.
    - Tap "Start Transcription" to begin recording from the microphone.
    - The app will start the transcription, and you will see the result on the screen in real-time.
    - Tap "Pause Transcription" to pause the recording.
    - Tap "Resume Transcription" to continue.
    - Tap "Stop Transcription" to end the transcription session.

## Code Integration

This example demonstrates the basic integration of the DianyaaiASR SDK for real-time transcription. Here are the key parts in the code:

### `MicrophoneManager.swift`

This file is responsible for capturing audio from the microphone and providing it as an `AsyncStream<Data>`. It also handles the audio format conversion to the format required by the ASR service (16kHz, 16-bit PCM, mono).

### `ASRViewModel.swift`

This file contains the core logic for interacting with the DianyaaiASR SDK.

1.  **Initialization:**
    In the `init()` method, we set up the `DianyaaiASRAPI` with the authentication token and bind to the `MicrophoneManager`'s error messages.

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

2.  **Real-Time Transcription:**
    The `startTranscription()` method starts the microphone recording and initiates the real-time transcription stream. It uses the `transcribeStream` method of the SDK, providing the audio stream from the `MicrophoneManager`. It then observes the results from the `asrStreamController`.

    ```swift
    func startTranscription() {
        // ...
        Task {
            do {
                // Start microphone recording
                await microphoneManager.startRecording()

                // Initialize ASR stream controller
                self.asrStreamController = asrApi.transcribeStream(audioSource: microphoneManager.sharedAudioStream)

                // Observe transcription results
                resultsTask = Task {
                    for await result in self.asrStreamController!.results {
                        // ... handle results
                    }
                }

                // Start the ASR stream
                asrStreamController?.start()
            } catch {
                // ... handle errors
            }
        }
    }
    ```

### `ASRView.swift`

This SwiftUI view provides the user interface for starting, stopping, and pausing transcription, and for displaying the real-time transcription results.
