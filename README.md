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

The SDK provides two main clients for speech recognition: `RealTimeTranscribeClient` for live audio streams and `FileTranscribeClient` for transcribing pre-recorded audio files.

### Real-time Transcription

Use `RealTimeTranscribeClient` to get transcriptions from a continuous audio stream (e.g., a microphone). The client uses modern Swift Concurrency and communicates over a WebSocket.

**Audio Format:** The client expects audio data in **16kHz, 16-bit, single-channel PCM** format.

**Example:**

```swift
import DianyaaiASR
import Foundation

// 1. Initialize the real-time client.
// The client is an actor, so all interactions with it must use `await`.
let client = createRealTimeTranscribeClient(authToken: "YOUR_AUTH_TOKEN")

// 2. Set up tasks to listen to the state and data streams.
// It's crucial to start listening *before* calling connect().

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
    for await message in client.dataStream {
        switch message.data {
        case .asrResult(let result):
            print("Final Result: \(result.text)")
        case .asrResultPartial(let result):
            print("Partial Result: \(result.text)")
        case .error(let serverError):
            print("Server Error: \(serverError.data)")
        case .stop:
            print("Server indicated end of transcription.")
            // The dataStream will finish after this message.
        }
    }
    print("Data stream finished.")
}

// 3. Connect to the server.
await client.connect()

// 4. Send audio data.
// In a real app, you would get this data from a microphone manager.
// The client automatically buffers and sends data in correctly sized chunks.
// The audio must be 16kHz, 16-bit, single-channel PCM.
await client.sendAudioChunk(someAudioData)

// 5. Indicate the end of audio.
// When you're done sending audio, call `stopSendingAudio()`.
// The client sends any remaining buffered audio and then a special
// "end" message to the server. The connection remains open to receive
// any final results.
await client.stopSendingAudio()

// 6. Disconnect.
// When you are completely finished, call `disconnect()` to close the
// WebSocket and release resources.
await client.disconnect()
```

### File Transcription

Use `FileTranscribeClient` to transcribe a local audio file. The client handles uploading the file and polling for the transcription status.

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

// 3. Listen for state changes and data updates from the streams.
Task {
    for await state in client.stateStream {
        print("Client state changed: \(state)")
        if case .failed(let error) = state {
            print("Client failed with error: \(error.localizedDescription)")
        }
    }
}

Task {
    for await message in client.dataStream {
        print("Received status: \(message.data.description)")
        
        // Check if the transcription is done
        if message.data == .done {
            print("Transcription complete!")
            if let summary = message.summaryMd {
                print("--- Summary ---")
                print(summary)
            }
            if let details = message.details {
                 print("--- Details ---")
                for detail in details {
                    print("Speaker \(detail.speaker) (\(detail.startTime)-\(detail.endTime)s): \(detail.text)")
                }
            }
            // The dataStream will finish after this message.
        } else if message.data.isFailed {
            print("Transcription failed with status: \(message.status)")
        }
    }
    print("Data stream has finished.")
}

// 4. Start the transcription process.
await client.start()
```