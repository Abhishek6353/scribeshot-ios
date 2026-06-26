import SwiftUI
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct AnalyzeScreenshotApp: App {
    let container: ModelContainer
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        if let container = try? ModelContainer(for: ScreenshotItem.self, configurations: config) {
            self.container = container
        } else {
            let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
            self.container = try! ModelContainer(for: ScreenshotItem.self, configurations: fallbackConfig)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task { @MainActor in
                        ProcessingQueue.shared.configure(with: container.mainContext)
                    }
                }
        }
        .modelContainer(container)
    }
}
