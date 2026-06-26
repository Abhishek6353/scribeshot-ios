import SwiftUI
import Photos

struct EmptyStateView: View {
    @State private var showingPermissionAlert = false
    @State private var isScanning = false

    private var permissionGranted: Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
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
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant photo library access in Settings to use Screenshot Analyzer.")
        }
    }
}
