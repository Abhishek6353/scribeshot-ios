import SwiftUI
import Photos

struct EmptyStateView: View {
    @Binding var showingSettings: Bool
    @State private var showingPermissionAlert = false
    @State private var isScanning = false
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var photoService = PhotoLibraryService.shared

    private var permissionGranted: Bool {
        photoService.authorizationStatus == .authorized || photoService.authorizationStatus == .limited
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.accent)

            Text("No Screenshots Yet")
                .font(.title2)
                .fontWeight(.semibold)

            if permissionGranted {
                if settings.isConfigured {
                    Text("Tap the button below to scan your photo library for screenshots.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        isScanning = true
                        Task {
                            await ProcessingQueue.shared.processNewScreenshots()
                            isScanning = false
                        }
                    } label: {
                        if isScanning {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Scan for Screenshots", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(isScanning)
                } else {
                    Text("An OpenAI API key is required to analyze and summarize your screenshots.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        showingSettings = true
                    } label: {
                        Label("Add API Key", systemImage: "key.horizontal")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Text("Grant photo library access to automatically import and organize your screenshots.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    Task {
                        let success = await PhotoLibraryService.shared.requestAuthorization()
                        if !success {
                            showingPermissionAlert = true
                        }
                    }
                } label: {
                    Label("Grant Photo Access", systemImage: "lock.open")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Spacer()
        }
        .alert("Photo Library Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To automatically detect and scan screenshots, this app requires access to your Photo Library. Please enable access in Settings.")
        }
    }
}
