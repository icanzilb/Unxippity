//  Created by Marin Todorov on 11/12/23.
//

import Foundation

protocol FileManagerProtocol: ObservableObject {
    func removeItem(at URL: URL) throws
    func fileExists(atPath path: String) -> Bool
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL]
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any]
}

extension FileManager: FileManagerProtocol { }

extension FileManager {
    static var app: any FileManagerProtocol {
        #if UITESTING
        return TestingFileManager.default
        #else
        return FileManager.default
        #endif
    }
}

class TestingFileManager: FileManagerProtocol {
    static let `default` = TestingFileManager()

    func removeItem(at URL: URL) throws { }

    var exists = true
    func fileExists(atPath path: String) -> Bool {
        return exists
    }

    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        // Downloads folder
        return [
            URL(fileURLWithPath: "/Users/me/Downloads")
        ]
    }

    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL] {
        // Downloads folder contents
        return [
            URL(
                fileURLWithPath: Bundle.main.url(forResource: "Xcode_15.0.1", withExtension: "xip")!.absoluteString.appending(".download")
            )
        ]
    }

    var modifiedDate: Date?
    var fileSize: UInt64?

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any] {
        return [
            .modificationDate: modifiedDate ?? Date(timeIntervalSinceNow: -1),
            .size: fileSize ?? 1024
        ]
    }
}
