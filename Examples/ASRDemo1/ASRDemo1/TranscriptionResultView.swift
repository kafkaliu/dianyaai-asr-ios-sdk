//
//  TranscriptionResultView.swift
//  ASRDemo1
//
//  Created by Kafka Liu on 2025/11/1.
//

import SwiftUI
import WebKit
import DianyaaiASR

struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print(htmlString)
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct TranscriptionResultView: View {
    let transcriptionStatus: DianyaaiASR.TranscriptionStatus

    private func html(for markdown: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                body {
                    font-family: -apple-system, sans-serif;
                    padding: 20px;
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                document.getElementById('content').innerHTML = marked.parse(`\(markdown)`);
            </script>
        </body>
        </html>
        """
    }

    var body: some View {
        TabView {
            if let overview = transcriptionStatus.overviewMd {
                WebView(htmlString: html(for: overview))
                .tabItem {
                    Label("Overview", systemImage: "doc.text")
                }
            }

            if let summary = transcriptionStatus.summaryMd {
                WebView(htmlString: html(for: summary))
                .tabItem {
                    Label("Summary", systemImage: "doc.text.magnifyingglass")
                }
            }

            if let details = transcriptionStatus.details {
                List(details.indices, id: \.self) { index in
                    let detail = details[index]
                    VStack(alignment: .leading) {
                        Text("\(detail.startTime) - \(detail.endTime)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(detail.text)
                            .font(.body)
                    }
                }
                .tabItem {
                    Label("Details", systemImage: "list.bullet")
                }
            }
        }
    }
}
