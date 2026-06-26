import SwiftUI
import Combine

struct ContentView: View {
    @State private var isOnboarded = AppSettings.shared.isOnboarded

    var body: some View {
        Group {
            if isOnboarded {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
        .onReceive(AppSettings.shared.objectWillChange) { _ in
            isOnboarded = AppSettings.shared.isOnboarded
        }
    }
}
