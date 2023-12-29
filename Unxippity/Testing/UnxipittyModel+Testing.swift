//
//  UnxipittyModel+Testing.swift
//  Unxippity
//
//  Created by Marin Todorov on 11/12/23.
//

import Foundation
import SwiftUI

extension UnxipittyModel {
    
    func startTesting() async throws {
        TestingFileManager.default.fileSize = 0
        TestingFileManager.default.exists = true

        try await Task.sleep(for: .seconds(1))
        let dm = try DownloadModel.downloads(matching: "Xcode").first!
        trackDownload(dm)
        for count in 1...5 {
            try await Task.sleep(for: .seconds(1))
            TestingFileManager.default.fileSize = UInt64(count * 275300000)
        }
        while locked {
            print("Wait model lock")
            try await Task.sleep(for: .seconds(1))
        }

        TestingFileManager.default.exists = false

        withAnimation {
            downloadModel = nil
            url = dm.finalDownloadedURL
            fileSize = 3456456324.formattedFileSize
        }
        try await Task.sleep(for: .seconds(1))
        for count in 1...9 {
            try await Task.sleep(for: .seconds(1))
            progress = Double(count) / 10.0
        }
        progress = 1.0
        let urlCopy = url!
        url = nil
        try postProcess(urlCopy)
        
        Task { [weak self] in
            try await self?.startTesting()
        }
    }
}
