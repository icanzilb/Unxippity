//
//  DownloadView.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/11/23.
//

import SwiftUI

struct DownloadView: View {
    @EnvironmentObject var model: UnxipittyModel
    @AppStorage("trackDownloads") var trackDownloads = true

    var download: DownloadModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 2) {
                ProgressView()
                    .scaleEffect(x: 0.4, y: 0.4)
                    .padding(.leading, -10)
                    .padding(.trailing, -6)

                Text("Downloading \(download.downloadedFileURL.lastPathComponent)...")
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()
            }

            Text("Progress: \(fileByteCountFormatter.string(fromByteCount: Int64(download.fileSize)))")
                .font(.callout.monospaced().bold())
                .foregroundStyle(.secondary)

            Spacer().frame(height: 20)

            HStack(content: {
                Toggle(isOn: $trackDownloads, label: {
                    Text("Automatically unarchive Xcode downloads")
                })
            })

            Spacer().frame(height: 16)

            PostUnarchiveOptionsView(includeTargetSelection: true)
        }
    }
}
