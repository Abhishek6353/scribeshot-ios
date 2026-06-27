import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            if settings.isOnboarded {
                DashboardView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: settings.isOnboarded)
    }
}
