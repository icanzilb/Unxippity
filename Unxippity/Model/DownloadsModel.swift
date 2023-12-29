//
//  DownloadsModel.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/11/23.
//

import Foundation
import Combine
import os

let downloadsLog = { true }() ? OSLog(subsystem: "com.unxippity", category: "Downloads") : .disabled

class DownloadModel: ObservableObject {

    let url: URL
    let downloadedFileURL: URL
    @Published var modified: Date
    @Published var fileSize: Int64

    var finalDownloadedURL: URL {
        return url
            .deletingLastPathComponent()
            .appendingPathComponent(downloadedFileURL.lastPathComponent)
    }

    init(url: URL, downloadedFileURL: URL, modified: Date, fileSize: Int64) {
        self.url = url
        self.downloadedFileURL = downloadedFileURL
        self.modified = modified
        self.fileSize = fileSize
    }

    static func downloads(matching: String? = nil) throws -> [DownloadModel] {
        let downloadsURL = FileManager.app.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

        let id = OSSignpostID(log: downloadsLog)
        os_signpost(.begin, log: downloadsLog, name: "read downloads", signpostID: id, "Reading files in %s", downloadsURL.path)
        defer {
            os_signpost(.end, log: downloadsLog, name: "read downloads", signpostID: id, "Ended")
        }

        let urls = try FileManager.app.contentsOfDirectory(
            at: downloadsURL,
            includingPropertiesForKeys: [.attributeModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
        )

        var results = [DownloadModel]()

        for url in urls where url.lastPathComponent.hasSuffix(".download") {
            guard matching == nil || url.lastPathComponent.contains(matching!) else {
                continue
            }

            let downloadedFileURL = url.appendingPathComponent(
                String(url.lastPathComponent.dropLast(".download".count))
            )

            let fileAttributes = (try FileManager.app.attributesOfItem(atPath: downloadedFileURL.path)) as NSDictionary

            guard let modifiedDate = fileAttributes.fileModificationDate() else {
                continue
            }

            results.append(
                DownloadModel(
                    url: url,
                    downloadedFileURL: downloadedFileURL,
                    modified: modifiedDate,
                    fileSize: Int64(fileAttributes.fileSize())
                )
            )
        }

        return results.sorted { $0.modified > $1.modified }
    }
}
