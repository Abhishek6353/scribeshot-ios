import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                permissionPage.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 72))
                .foregroundStyle(.accent)

            Text("Screenshot Analyzer")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Automatically organize your screenshots with AI.\nExtract text, generate titles, and search everything instantly.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 12) {
                Label("On-device OCR text extraction", systemImage: "text.viewfinder")
                Label("AI-powered titles & summaries", systemImage: "sparkles")
                Label("Full-text search across everything", systemImage: "magnifyingglass")
                Label("Privacy-first: data stays on your device", systemImage: "lock.shield")
            }
            .font(.subheadline)

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentIndigo)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private var permissionPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text("Photo Library Access")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Screenshot Analyzer needs access to your photo library to detect and import screenshots.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                Task {
                    let success = await PhotoLibraryService.shared.requestAuthorization()
                    completeOnboarding()
                }
            } label: {
                Label("Grant Access", systemImage: "lock.open")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentIndigo)
            .padding(.horizontal, 32)

            Button("Not now") {
                completeOnboarding()
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private func completeOnboarding() {
        AppSettings.shared.isOnboarded = true
    }
}
