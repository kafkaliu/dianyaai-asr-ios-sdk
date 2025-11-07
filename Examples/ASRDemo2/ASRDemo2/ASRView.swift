//
//  ASRView.swift
//  ASRDemo2
//
//  Created by Kafka Liu on 2025/11/1.
//

import SwiftUI
import UniformTypeIdentifiers

struct ASRView: View {
    @StateObject private var viewModel = ASRViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.transcriptText)
                            .font(.body)
                            .foregroundColor(.primary)

                        Text(viewModel.partialTranscriptText)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()

                HStack(spacing: 20) {
                    if !viewModel.isTranscribing && !viewModel.isPaused {
                        Button("开始") {
                            Task { await viewModel.startTranscription()}
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    } else if viewModel.isPaused {
                        Button("恢复") {
                            viewModel.resumeTranscription()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    } else if viewModel.isTranscribing {
                        Button("暂停") {
                            viewModel.pauseTranscription()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }

                    if viewModel.isTranscribing || viewModel.isPaused {
                        Button("终止") {
                            viewModel.stopTranscription()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("实时语音转写 Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                        Image(systemName: "gear")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("错误"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }
}
