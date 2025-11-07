//
//  ASRViewModel.swift
//  ASRDemo1
//
//  Created by Kafka Liu on 2025/11/1.
//

import Foundation
import Combine
import AVFoundation
import DianyaaiASR

@MainActor
class ASRViewModel: ObservableObject {
    @Published var transcriptText: String = ""
    @Published var partialTranscriptText: String = ""
    @Published var isTranscribing: Bool = false
    @Published var isPaused: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var authToken: String = ""

    private let microphoneManager = MicrophoneManager()
    private var cancellables = Set<AnyCancellable>()
    private var resultsTask: Task<Void, Never>?

    init() {
        setupAuthToken()
        setupMicrophoneManagerBindings()
    }

    private func setupAuthToken() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
    }

    private func setupMicrophoneManagerBindings() {
        microphoneManager.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.alertMessage = message
                self?.showAlert = true
            }
            .store(in: &cancellables)
    }

    func saveAuthToken() {
        UserDefaults.standard.set(self.authToken, forKey: "authToken")
    }

    func startTranscription() async {
        guard !isTranscribing else { return }

        transcriptText = ""
        partialTranscriptText = ""
        isPaused = false
        isTranscribing = true

        let asrApi = createRealTimeTranscribeClient(authToken: self.authToken)

        Task {
            // Start microphone recording
            await microphoneManager.startRecording()

            // Observe transcription results
            resultsTask = Task {
                for await result in asrApi.dataStream {
                    switch result.data {
                        case .asrResult(let data):
                            if !data.text.isEmpty {
                                self.transcriptText += (self.transcriptText.isEmpty ? "" : "\n") + data.text
                                self.partialTranscriptText = "" // Clear partial after final result
                            }
                        case .asrResultPartial(let data):
                            self.partialTranscriptText = data.text
                        case .error(let error):
                            self.alertMessage = "Transcription error: \(error)"
                            self.showAlert = true
                            self.stopTranscription()
                        case .stop:
                            print("ASR service indicated stop.")
                        }
                }
                print("Results stream ended.")
            }

            // Start the ASR stream
//            await asrApi.connect()
            print("Transcription started.")
        }
        
        Task {
            for await data in microphoneManager.sharedAudioStream {
                await asrApi.sendAudioChunk(data)
            }
        }
        
        await asrApi.connect()
    }

    func pauseTranscription() {
        guard isTranscribing && !isPaused else { return }
        microphoneManager.pauseRecording()
//        asrStreamController?.pause()
        isPaused = true
        print("Transcription paused.")
    }

    func resumeTranscription() {
        guard isTranscribing && isPaused else { return }
        microphoneManager.resumeRecording()
//        asrStreamController?.resume()
        isPaused = false
        print("Transcription resumed.")
    }

    func stopTranscription() {
        guard isTranscribing else { return }

        microphoneManager.stopRecording()
//        asrStreamController?.stop()
//        asrStreamController = nil
        resultsTask?.cancel()
        resultsTask = nil

        isTranscribing = false
        isPaused = false
        partialTranscriptText = "" // Clear any remaining partial text
        print("Transcription stopped.")
    }
}

