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

    private var asrApi: DianyaaiASRAPI?
    private var asrStreamController: DianyaaiASR.RealTimeTranscriptionController?
    private let microphoneManager = MicrophoneManager()
    private var cancellables = Set<AnyCancellable>()
    private var resultsTask: Task<Void, Never>?

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
        updateASRAPI()
    }

    func startTranscription() {
        guard !isTranscribing else { return }

        transcriptText = ""
        partialTranscriptText = ""
        isPaused = false
        isTranscribing = true

        Task {
            do {
                // Start microphone recording
                await microphoneManager.startRecording()

                // Initialize ASR stream controller
                guard let asrApi = asrApi else {
                    alertMessage = "ASR API is not initialized. Please check your auth token."
                    showAlert = true
                    isTranscribing = false
                    return
                }
                self.asrStreamController = asrApi.transcribeStream(audioSource: microphoneManager.sharedAudioStream)

                // Observe transcription results
                resultsTask = Task {
                    for await result in self.asrStreamController!.results {
                        DispatchQueue.main.async {
                            switch result {
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
                                // The service might stop on its own, but we still manage our local state
                                // self.stopTranscription() // This might be called twice if user also taps stop
                            }
                        }
                    }
                    print("Results stream ended.")
                }

                // Start the ASR stream
                asrStreamController?.start()
                print("Transcription started.")

            } catch {
                alertMessage = "Failed to start transcription: \(error.localizedDescription)"
                showAlert = true
                isTranscribing = false
            }
        }
    }

    func pauseTranscription() {
        guard isTranscribing && !isPaused else { return }
        microphoneManager.pauseRecording()
        asrStreamController?.pause()
        isPaused = true
        print("Transcription paused.")
    }

    func resumeTranscription() {
        guard isTranscribing && isPaused else { return }
        microphoneManager.resumeRecording()
        asrStreamController?.resume()
        isPaused = false
        print("Transcription resumed.")
    }

    func stopTranscription() {
        guard isTranscribing else { return }

        microphoneManager.stopRecording()
        asrStreamController?.stop()
        asrStreamController = nil
        resultsTask?.cancel()
        resultsTask = nil

        isTranscribing = false
        isPaused = false
        partialTranscriptText = "" // Clear any remaining partial text
        print("Transcription stopped.")
    }
}

