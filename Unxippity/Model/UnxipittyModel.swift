import Foundation
import Combine
import libunxip
import SwiftUI
import Cocoa

extension URL {
    static let empty = URL(fileURLWithPath: "/")
}

let fileByteCountFormatter: ByteCountFormatter = {
    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useAll]
    bcf.countStyle = .file
    return bcf
}()

extension Double {
    var formattedFileSize: String  {
        return fileByteCountFormatter.string(fromByteCount: Int64(self))
    }
}

@MainActor
class UnxipittyModel: ObservableObject {
    @Published var url: URL? {
        didSet {
            guard let sourceURL = url else {
                return
            }
            Task.detached { [unowned self] in
                do {
                    try await self.doUnxip(sourceURL)
                } catch {
                    await MainActor.run {
                        switch error {
                        case let error as CocoaError:
                            self.errorMessage = error.localizedDescription
                        default:
                            self.errorMessage = String(describing: error)
                        }
                    }
                }
            }
        }
    }
    @Published var targetURL: URL?
    @Published var progress = 0.0
    @Published var fileSize: String?

    @Published var errorMessage: String?

    @AppStorage("deleteSourceFile") var deleteSourceFile = false
    @AppStorage("beepWhenDone") var beepWhenDone = false
    @AppStorage("launchWhenDone") var launchWhenDone = false
    @AppStorage("closeWhenDone") var closeWhenDone = false

    @AppStorage("extractDestination") var extractDestination = "."

    @Published private(set) var locked = false {
        willSet {
            if newValue {
                lockUUID = UUID()
            }
        }
    }
    
    private var lockUUID = UUID()

    func lock() -> UUID {
        locked = true
        lockUUID = UUID()
        return lockUUID
    }

    @discardableResult
    func unlock(with: UUID) -> Bool {
        guard with == lockUUID else {
            return false
        }
        assert(locked)
        locked = false
        return true
    }

    var finalURL: URL? {
        return self.targetURL ?? {
            guard let url else { return nil }
            let name = String(url.lastPathComponent.dropLast(".xip".count))
            return url.deletingLastPathComponent()
                .appendingPathComponent(name)
        }()
    }

    func reset() {
        targetURL = nil
        progress = 0.0
        fileSize = nil
        errorMessage = nil
    }

    func doUnxip(_ sourceURL: URL) async throws {
        #if UITESTING
        return
        #endif

        let containerDirectoryURL = sourceURL.deletingLastPathComponent()
        FileManager.default.changeCurrentDirectoryPath(containerDirectoryURL.path)

        let handle = try FileHandle(forReadingFrom: sourceURL)
        let totalCompressedBytes = Double(handle.availableData.count)

        fileSize = totalCompressedBytes.formattedFileSize

        try handle.seek(toOffset: 0)

        var bytes = 0
        var files = 0
        var lastReportedCount = 0

        let bytesPercentDelta = Int(totalCompressedBytes / 100.0)

        let reader = DataReader.data(
            readingFrom: handle.fileDescriptor, 
            rootURL: containerDirectoryURL,
            streamingDelegate: { bytes += $0 }
        )
        var iterator = reader.makeAsyncIterator()

        let fileSource = AsyncThrowingStream {
            try await iterator.next()
        }

        let dryRun = false
        let compress = false

        for try await file in Unxip.makeStream(
            from: .xip(wrapping: fileSource),
            to: .disk,
            input: DataReader(data: fileSource), 
            rootURL: containerDirectoryURL,
            nil,
            nil,
            .init(compress: compress, dryRun: dryRun)
        ) {
            if file.type == .regular {
                files += 1
                if bytes - lastReportedCount > bytesPercentDelta {
                    lastReportedCount = bytes

                    Task { @MainActor in
                        let progress = Double(bytes) / totalCompressedBytes
                        self.progress = progress
                    }
                }
            }
        }
        print("Final \(lastReportedCount) bytes")
        
        reset()

        try postProcess(sourceURL)
    }

    func postProcess(_ url: URL) throws {
        if beepWhenDone {
            NSSound(named: "Bottle")?.play()
        }

        if deleteSourceFile {
            Task {
                try FileManager.app.removeItem(at: url)
            }
        }

        if let finalURL {
            if launchWhenDone {
                NSWorkspace.shared.open(finalURL)
            } else {
                NSWorkspace.shared.selectFile(
                    finalURL.path,
                    inFileViewerRootedAtPath: finalURL.deletingLastPathComponent().path
                )
            }
        }

        if closeWhenDone {
            NSApp.terminate(nil)
        }
    }

    @Published var downloadModel: DownloadModel?

    func runFromDownloadsFolder() throws {
        let retry: ()-> Void = {
            Task { [weak self] in
                try? await Task.sleep(for: .seconds(5))
                try self?.runFromDownloadsFolder()
            }
        }

        print("Checking for downloads")

        guard let newestDownload = try? DownloadModel.downloads(matching: "Xcode").first else {
            retry()
            return
        }
        print("Candidate: \(newestDownload.url.path)")

        guard newestDownload.modified.distance(to: Date()) < 10 else {
            print("Distance: \(newestDownload.modified.distance(to: Date()))")
            retry()
            return
        }
        print("Download found")
        
        trackDownload(newestDownload)
    }

    func trackDownload(_ model: DownloadModel) {
        guard FileManager.app.fileExists(atPath: model.downloadedFileURL.path) else {
            if FileManager.app.fileExists(atPath: model.finalDownloadedURL.path) {
                Task { [weak self] in
                    guard let self else { return }
                    while locked {
                        print("Wait model lock")
                        try await Task.sleep(for: .seconds(1))
                    }
                    withAnimation {
                        self.downloadModel = nil
                        self.url = model.finalDownloadedURL
                    }
                }
            }
            return
        }

        do {
            let fileAttributes = (try FileManager.app.attributesOfItem(atPath: model.downloadedFileURL.path)) as NSDictionary
            model.fileSize = Int64(fileAttributes.fileSize())
        } catch { }

        downloadModel = model

        Task { [weak self] in
            try await Task.sleep(for: .seconds(1))
            self?.trackDownload(model)
        }
    }
}

func suggestedDownloadedFileName(from: URL) -> URL {
    let name = from.lastPathComponent
    return from.deletingLastPathComponent()
        .appendingPathComponent(String(name.dropLast(".download".count)))
}
