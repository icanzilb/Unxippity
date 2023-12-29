import SwiftUI
import libunxip

struct ContentView: View {
    @EnvironmentObject var model: UnxipittyModel
    @AppStorage("trackDownloads") var trackDownloads = true

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                IconPreview()

                VStack(alignment: .leading) {
                    if let errorMessage = model.errorMessage {
                        ErrorView(message: errorMessage)
                    }

                    if let downloadModel = model.downloadModel {
                        DownloadView(download: downloadModel)
                    } else if let _ = model.url {
                        UnarchiveView()
                    }
                }
            }
        }
        .frame(width: 520)
        .padding(20)
        .onAppear {
            #if UITESTING
            Task { try await model.startTesting() }
            #else
            checkDownloads()
            #endif
        }
        .onChange(of: trackDownloads, perform: { _ in
            #if !TESTING
            checkDownloads()
            #endif
        })
    }

    func checkDownloads() {
        do {
            if trackDownloads {
                try model.runFromDownloadsFolder()
            }
        } catch {
            model.errorMessage = error.localizedDescription
        }
    }
}
