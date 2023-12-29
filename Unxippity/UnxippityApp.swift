import SwiftUI

@main
struct BreadcrumbsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var model = UnxipittyModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .navigationTitle("Unxipitty")
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
    }
}
