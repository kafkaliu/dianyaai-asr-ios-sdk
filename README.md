# DianyaaiASR iOS SDK

DianyaaiASR is an iOS SDK for integrating Dianya AI's Automatic Speech Recognition (ASR) services into your iOS applications.

## Features

- File transcription: Transcribe audio files and get the results.
- Real-time transcription from a continuous audio stream.

## Installation

This project is a Swift Package. You can add it to your Xcode project by following these steps:

1. In Xcode, go to **File > Add Packages...**.
2. In the "Search or Enter Package URL" field, enter the URL of this repository.
3. Click **Add Package**.

## Usage

### File Transcription

To transcribe an audio file, you need to initialize the `DianyaaiASRAPI` with your authentication token and then call the `transcribeFile` method.

```swift
import DianyaaiASR
import Foundation

// 1. Configure the SDK with your authentication token.
let configuration = DianyaaiASRConfiguration(authToken: "YOUR_AUTH_TOKEN")

// 2. Initialize the API client.
let api = DianyaaiASRAPI(configuration: configuration)

// 3. Get the URL of the audio file you want to transcribe.
guard let fileURL = Bundle.main.url(forResource: "myaudio", withExtension: "mp3") else {
    print("Audio file not found.")
    return
}

// 4. Transcribe the file.
Task {
    do {
        let transcriptionStatus = try await api.transcribeFile(fileURL: fileURL)
        
        // 5. Handle the transcription result.
        if transcriptionStatus.status == "done" {
            if let details = transcriptionStatus.details {
                for detail in details {
                    print("Speaker \(detail.speaker): \(detail.text) (\(detail.startTime)s - \(detail.endTime)s)")
                }
            }
        } else {
            print("Transcription failed with status: \(transcriptionStatus.status)")
        }
    } catch {
        print("An error occurred: \(error)")
    }
}
```

### Error Handling

The `transcribeFile` method can throw errors. You should wrap the call in a `do-catch` block to handle potential errors, such as network issues or API errors.

### Real-time Transcription

The SDK provides a powerful and flexible API for real-time transcription from a continuous audio stream (e.g., from a microphone).

The API is designed around modern Swift concurrency. You provide a stream of audio data, and in return, you get a controller object that lets you manage the transcription lifecycle (`start`, `pause`, `resume`, `stop`) and a stream of transcription results.

**Example:**

```swift
import DianyaaiASR
import Foundation

// 1. Configure and initialize the API client.
let configuration = DianyaaiASRConfiguration(authToken: "YOUR_AUTH_TOKEN")
let api = DianyaaiASRAPI(configuration: configuration)

// 2. Create an `AsyncStream` to act as your audio source.
//    In a real app, you would get this stream from a microphone manager.
let (audioStream, audioContinuation) = AsyncStream.makeStream(of: Data.self)

// 3. Get the transcription controller by providing the audio source.
let controller = api.transcribeStream(audioSource: audioStream)

// 4. Start a task to listen for transcription results.
Task {
    for await result in controller.results {
        switch result {
        case .asrResult(let data), .asrResultPartial(let data):
            print("Received text: \(data.text)")
        case .error(let error):
            print("Received an error: \(error)")
        case .stop:
            print("Server indicated end of transcription.")
        }
    }
    print("Result stream finished.")
}

// 5. You now have full control over the lifecycle.

// Start the transcription. It will begin processing audio from the stream.
controller.start()

// Push audio data into the stream.
// (In a real app, your microphone manager would do this.)
// audioContinuation.yield(someAudioDataChunk)
// audioContinuation.yield(anotherAudioDataChunk)

// Pause the transcription. Audio chunks sent during pause are ignored.
controller.pause()

// Resume the transcription. It will start processing audio from the
// current point in the stream.
controller.resume()

// Push more audio data.
// audioContinuation.yield(moreAudioData)

// When you are completely done, stop the controller.
// This will terminate the connection and release all resources.
controller.stop()

// It's also good practice to finish the audio stream continuation
// when the audio source is depleted.
audioContinuation.finish()
```