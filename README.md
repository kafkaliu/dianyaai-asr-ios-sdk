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

To transcribe an audio file, you create a `FileTranscribeClient` and call the `start` method. The client provides two streams: `stateStream` for monitoring the client's state and `statusStream` for receiving transcription status updates.

**Example:**

```swift
import DianyaaiASR
import Foundation

// 1. Get the URL of the audio file you want to transcribe.
guard let fileURL = Bundle.main.url(forResource: "myaudio", withExtension: "mp3") else {
    print("Audio file not found.")
    return
}

// 2. Create the file transcribe client.
let client = createFileTranscribeClient(authToken: "YOUR_AUTH_TOKEN", fileURL: fileURL)

// 3. Listen for state changes and status updates from the streams.
Task {
    for await state in client.stateStream {
        print("Client state changed: \(state)")
        if case .failed(let error) = state {
            print("Client failed with error: \(error.localizedDescription)")
        }
    }
}

Task {
    for await status in client.statusStream {
        print("Received status: \(status.status)")
        if status.status == "done" {
            if let details = status.details {
                for detail in details {
                    print("Speaker \(detail.speaker): \(detail.text)")
                }
            }
        }
    }
    print("Status stream has finished.")
}

// 4. Start the transcription process.
await client.start()
```

### Real-time Transcription

The SDK provides a `RealTimeTranscribeClient` for real-time transcription from a continuous audio stream (e.g., from a microphone). The client is built using modern Swift Concurrency (async/await) and communicates over WebSocket.

**Key Features:**

-   **State Management:** The client exposes a `stateStream` (`AsyncStream<ClientState>`) to monitor its connection status (e.g., `.connecting`, `.connected`, `.reconnecting`, `.stopped`).
-   **Result Streaming:** Transcription results are delivered through a `messageStream` (`AsyncStream<ServerMessage>`), which provides strongly-typed events like `.asrResult` (final), `.asrResultPartial` (interim), and `.error`.
-   **Automatic Reconnection:** The client automatically handles unexpected disconnects with an exponential backoff strategy.
-   **Thread Safety:** The client is an `actor`, ensuring that all its methods and properties are safe to access from any thread.

**Example:**

```swift
import DianyaaiASR
import Foundation

// 1. Initialize the real-time client.
//    The client is an actor, so all interactions with it must use `await`.
let client = createRealTimeTranscribeClient(authToken: "YOUR_AUTH_TOKEN")

// 2. Set up tasks to listen to the state and message streams.
//    It's crucial to start listening *before* calling connect().

// Listen for connection state changes
Task {
    for await state in client.stateStream {
        print("Client state changed: \(state)")
        if case .stopped(let error) = state {
            if let error = error {
                print("Client stopped with error: \(error.localizedDescription)")
            } else {
                print("Client stopped gracefully.")
            }
        }
    }
}

// Listen for transcription messages from the server
Task {
    for await message in client.messageStream {
        switch message {
        case .asrResult(let result):
            print("Final Result: \(result.text)")
        case .asrResultPartial(let result):
            print("Partial Result: \(result.text)")
        case .error(let serverError):
            print("Server Error: \(serverError.data)")
        case .stop:
            print("Server indicated end of transcription.")
        }
    }
    print("Message stream finished.")
}

// 3. Connect to the server.
await client.connect()

// 4. Send audio data.
//    In a real app, you would get this data from a microphone manager.
//    The client buffers the data and sends it in chunks of the correct size.
//    You can call `sendAudioChunk` from any thread.
//
//    client.sendAudioChunk(someAudioData)

// 5. Indicate the end of audio.
//    When you're done sending audio, call `stopSendingAudio()`.
//    The client will send any remaining buffered audio and then a special
//    "end" message to the server. The connection remains open to receive
//    any final results.
await client.stopSendingAudio()

// 6. Disconnect.
//    When you are completely finished and want to close the connection,
//    call `disconnect()`. This will close the WebSocket and release resources.
await client.disconnect()
```