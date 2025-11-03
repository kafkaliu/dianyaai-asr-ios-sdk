//
//  ASRView.swift
//  ASRDemo1
//
//  Created by Kafka Liu on 2025/11/1.
//

import SwiftUI
import UniformTypeIdentifiers

struct ASRView: View {
    @StateObject private var viewModel = ASRViewModel()
    @State private var isShowingFilePicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isTranscribing {
                    ProgressView()
                } else {
                    if let status = viewModel.transcriptionStatus {
                        TranscriptionResultView(transcriptionStatus: status)
                    } else {
                        Text(viewModel.transcriptionResult)
                            .padding()
                    }
                }

                Spacer()

                Button(action: {
                    isShowingFilePicker = true
                }) {
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("ASR Demo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(viewModel: viewModel)) {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                viewModel.setup()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("提示"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("确定")))
            }
            .fileImporter(isPresented: $isShowingFilePicker, allowedContentTypes: [.audio]) { result in
                switch result {
                case .success(let url):
                    viewModel.transcribeFile(url: url)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
