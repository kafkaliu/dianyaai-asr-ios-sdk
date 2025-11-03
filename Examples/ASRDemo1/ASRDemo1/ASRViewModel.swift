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
    @Published var transcriptionResult = "点击下方按钮开始转写"
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isTranscribing = false
    @Published var transcriptionStatus: DianyaaiASR.TranscriptionStatus?
    @Published var authToken = ""

    private var asrApi: DianyaaiASRAPI?

    func setup() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        let config = DianyaaiASR.DianyaaiASRConfiguration(authToken: self.authToken)
        self.asrApi = DianyaaiASRAPI(configuration: config)
    }

    func saveAuthToken() {
        UserDefaults.standard.set(self.authToken, forKey: "authToken")
    }

    func transcribeFile(url: URL) {
        isTranscribing = true
        Task {
            do {
                if let status = try await asrApi?.transcribeFile(fileURL: url) {
                    if status.status == "done" {
                        self.transcriptionStatus = status
                    } else {
                        self.transcriptionResult = "转写失败: \(status.message ?? "未知错误")"
                    }
                }
            } catch {
                self.transcriptionResult = "转写失败: \(error.localizedDescription)"
            }
            isTranscribing = false
        }
    }
}
