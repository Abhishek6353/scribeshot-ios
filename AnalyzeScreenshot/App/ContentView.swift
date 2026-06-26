import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Group {
            if settings.isOnboarded {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
    }
}
