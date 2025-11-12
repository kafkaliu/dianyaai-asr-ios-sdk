//
//  SettingsView.swift
//  ASRDemo2
//
//  Created by Kafka Liu on 2025/11/1.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ASRViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Auth Token")) {
                TextField("输入 Auth Token", text: $viewModel.authToken)
                Button(action: {
                    viewModel.saveAuthToken()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存")
                }
            }
        }
        .navigationTitle("设置")
    }
}
