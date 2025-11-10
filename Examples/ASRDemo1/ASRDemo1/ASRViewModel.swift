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

class ASRViewModel: ObservableObject {
    @Published var transcriptionResult = "点击下方按钮开始转写"
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isTranscribing = false
    @Published var transcriptionStatus: FileTranscribeMessage?
    @Published var authToken = ""

    func setup() {
        self.authToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
    }

    func saveAuthToken() {
        UserDefaults.standard.set(self.authToken, forKey: "authToken")
    }

    func transcribeFile(url: URL) async {
        // For files that are not in the app's sandbox, we need to request access first.
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        await MainActor.run {
            self.isTranscribing = true
            self.transcriptionStatus = nil
        }

        let asrApi = createFileTranscribeClient(authToken: self.authToken, fileURL: url)

        let processingTask = Task {
            for await data in asrApi.dataStream {
                await MainActor.run {
                    switch data.data {
                    case .done:
                        self.transcriptionStatus = data
                        self.isTranscribing = false
                    case .failed, .clientTimeout:
                        self.transcriptionResult = "转写失败: \(data.message ?? "未知错误")"
                        self.isTranscribing = false
                    case .pending:
                        self.transcriptionResult = "转写状态: 等待中..."
                    case .running:
                        self.transcriptionResult = "转写状态: 进行中..."
                    case .clientError:
                        self.transcriptionResult = "客户端错误: 未知错误"
                        self.isTranscribing = false
                    case .unknown(let value):
                        self.transcriptionResult = "未知状态: \(value)"
                        self.isTranscribing = false
                    }
                }
            }
        }

        await asrApi.start()
        // Wait for the stream processing to complete to ensure that we don't
        // exit the scope of `startAccessingSecurityScopedResource` prematurely.
        await processingTask.value
    }
}
