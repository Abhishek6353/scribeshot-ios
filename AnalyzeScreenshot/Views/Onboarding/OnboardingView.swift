import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Subtle premium gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.16), // Deep dark indigo
                    Color(red: 0.03, green: 0.03, blue: 0.05)  // Almost black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Soft glow effect behind the top area
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(y: -180)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    permissionPage.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()

            // Glowing Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                    )
                
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, Color(red: 0.5, green: 0.5, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: Color.accentColor.opacity(0.35), radius: 20)

            VStack(spacing: 8) {
                Text("Screenshot Analyzer")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Your personal, AI-powered digital memory notebook.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Glassmorphic Feature Card
            VStack(alignment: .leading, spacing: 18) {
                FeatureRow(
                    icon: "text.viewfinder",
                    title: "On-Device OCR",
                    description: "Instantly extracts text from your screenshots locally."
                )
                FeatureRow(
                    icon: "sparkles",
                    title: "AI Analysis",
                    description: "Generates smart titles, summaries, and tags."
                )
                FeatureRow(
                    icon: "magnifyingglass",
                    title: "Instant Search",
                    description: "Find any screenshot by searching for text inside it."
                )
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Secure Processing",
                    description: "Your images stay on-device; only text is sent to OpenAI."
                )
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)

            Spacer()

            // Styled Call-to-action Button
            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.accentColor, Color(red: 0.35, green: 0.35, blue: 0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 12, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40) // Raised slightly above page indicators
        }
    }

    private var permissionPage: some View {
        VStack(spacing: 28) {
            Spacer()

            // Glowing Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                    )
                
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, Color(red: 0.5, green: 0.5, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: Color.accentColor.opacity(0.35), radius: 20)

            VStack(spacing: 8) {
                Text("Photo Library Access")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                
                Text("Automatic Screenshot Sync")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Glassmorphic Info Card
            VStack(spacing: 12) {
                Text("Why we need this permission")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("To automatically detect when you take a screenshot and perform text extraction, we need access to read your Photo Library. All image scanning is done on-device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    Task {
                        _ = await PhotoLibraryService.shared.requestAuthorization()
                        completeOnboarding()
                    }
                } label: {
                    Label("Grant Access", systemImage: "lock.open.fill")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.accentColor, Color(red: 0.35, green: 0.35, blue: 0.95)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.horizontal, 24)

                Button("Not now, set up later") {
                    completeOnboarding()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 32)
        }
    }

    private func completeOnboarding() {
        AppSettings.shared.isOnboarded = true
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.accent)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
