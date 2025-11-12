//
//  ASRViewModel.swift
//  ASRDemo2
//
//  Created by Kafka Liu on 2025/11/1.
//

import AVFoundation
import Combine
import DianyaaiASR
import Foundation
import OSLog

@MainActor
class ASRViewModel: ObservableObject {
    @Published var transcriptText: String = ""
    @Published var partialTranscriptText: String = ""
    @Published var isTranscribing: Bool = false
    @Published var isPaused: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var authToken: String = ""
    @Published var savedFileName: String?
    @Published var showFileSavedAlert: Bool = false

    private static let subsystem = "com.dianyaai.DianyaaiASR.Examples.ASRDemo2"
    private static let `default` = os.Logger(subsystem: subsystem, category: "Default")

    private let microphoneManager = MicrophoneManager()
    private var cancellables = Set<AnyCancellable>()
    private var resultsTask: Task<Void, Never>?
    private var asrApi: RealTimeTranscribeClient?

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

        self.asrApi = createRealTimeTranscribeClient(
            authToken: self.authToken, audioChunkSize: 3200)
        guard let asrApi = self.asrApi else {
            Self.default.error("Failed to create RealTimeTranscribeClient.")
            isTranscribing = false
            return
        }

        Task {
            // Start microphone recording
            await microphoneManager.startRecording()

            // Observe transcription results
            resultsTask = Task {
                for await result in asrApi.dataStream {
                    switch result.data {
                    case .asrResult(let data):
                        if !data.text.isEmpty {
                            self.transcriptText +=
                                (self.transcriptText.isEmpty ? "" : "\n") + data.text
                            self.partialTranscriptText = ""  // Clear partial after final result
                        }
                    case .asrResultPartial(let data):
                        self.partialTranscriptText = data.text
                    case .error(let error):
                        self.alertMessage = "Transcription error: \(error)"
                        self.showAlert = true
                        await self.stopTranscription()
                    case .stop:
                        Self.default.log("ASR service indicated stop.")
                    }
                }
                Self.default.log("Results stream ended.")
            }

            // Start the ASR stream
            //            await asrApi.connect()
            Self.default.log("Transcription started.")
        }
        await asrApi.connect()

        Task {
            for await data in microphoneManager.sharedAudioStream {
                await asrApi.sendAudioChunk(data)
            }
        }
    }

    func pauseTranscription() {
        guard isTranscribing && !isPaused else { return }
        microphoneManager.pauseRecording()
        //        asrStreamController?.pause()
        isPaused = true
        Self.default.log("Transcription paused.")
    }

    func resumeTranscription() {
        guard isTranscribing && isPaused else { return }
        microphoneManager.resumeRecording()
        //        asrStreamController?.resume()
        isPaused = false
        Self.default.log("Transcription resumed.")
    }

    func stopTranscription() async {
        guard isTranscribing else { return }

        await asrApi?.disconnect()
        asrApi = nil

        let pcmFileName = microphoneManager.saveRecording()

        microphoneManager.stopRecording()

        if let pcmFileName = pcmFileName {
            self.savedFileName = "PCM file saved as: \(pcmFileName)"
            self.showFileSavedAlert = true
        }

        //        asrStreamController?.stop()
        //        asrStreamController = nil
        resultsTask?.cancel()
        resultsTask = nil

        isTranscribing = false
        isPaused = false
        // partialTranscriptText = ""  // Clear any remaining partial text
        Self.default.log("Transcription stopped.")
        Self.default.log("Final transcript: \(self.transcriptText) \(self.partialTranscriptText)")
    }
}
