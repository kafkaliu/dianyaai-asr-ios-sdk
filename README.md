# DianyaaiASR iOS SDK

DianyaaiASR is an iOS SDK for integrating Dianya AI's Automatic Speech Recognition (ASR) services into your iOS applications.

## Features

- File transcription: Transcribe audio files and get the results.
- Real-time transcription (coming soon).

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