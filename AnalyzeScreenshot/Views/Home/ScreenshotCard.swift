import SwiftUI
import Photos

struct ScreenshotCard: View {
    let item: ScreenshotItem

    @State private var thumbnail: UIImage?
    private let photoService = PhotoLibraryService.shared

    private var shouldShowSkeleton: Bool {
        switch item.processingStatus {
        case .pending, .ocrInProgress, .aiProcessing:
            return true
        case .ocrComplete:
            return AppSettings.shared.isConfigured
        case .complete, .failed:
            return false
        }
    }

    private var displayTitle: String {
        if !item.title.isEmpty {
            return item.title
        }
        switch item.processingStatus {
        case .pending, .ocrInProgress, .aiProcessing:
            return "Processing..."
        case .ocrComplete:
            return (!item.sourceApp.isEmpty && item.sourceApp != "Unknown") ? "Screenshot (\(item.sourceApp))" : "Screenshot"
        case .complete, .failed:
            return "Screenshot"
        }
    }

    private var displaySummary: String {
        if !item.summary.isEmpty {
            return item.summary
        }
        switch item.processingStatus {
        case .pending, .ocrInProgress, .aiProcessing:
            return ""
        case .ocrComplete:
            if !item.rawOCRText.isEmpty {
                return item.rawOCRText
            }
            return "OCR completed. No text detected."
        case .complete:
            return "No text detected."
        case .failed:
            return "Processing failed."
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnailView
                .frame(width: 90, height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                if shouldShowSkeleton {
                    VStack(alignment: .leading, spacing: 8) {
                        // Title skeleton (2 lines)
                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .frame(width: 140, height: 14)
                            .skeletonPulse()

                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .frame(width: 90, height: 14)
                            .skeletonPulse()

                        Spacer().frame(height: 4)

                        // Summary skeleton (3 lines)
                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .frame(maxWidth: .infinity)
                            .frame(height: 10)
                            .skeletonPulse()
                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .frame(maxWidth: .infinity)
                            .frame(height: 10)
                            .skeletonPulse()
                        Capsule()
                            .fill(Color(.tertiarySystemBackground))
                            .frame(width: 160, height: 10)
                            .skeletonPulse()
                    }
                    .transition(.opacity)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(displayTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundStyle(.primary)

                        let summaryText = displaySummary
                        if !summaryText.isEmpty {
                            Text(summaryText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: shouldShowSkeleton)

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await loadThumbnail()
        }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
                .fill(Color(.tertiarySystemBackground))
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.tertiary)
                }
        }
    }

    private func loadThumbnail() async {
        let assets = photoService.fetchScreenshotsFromIdentifiers([item.localIdentifier])
        guard let asset = assets.firstObject else { return }
        thumbnail = await photoService.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300))
    }
}

// MARK: - Skeleton Pulse Animation Helper

struct SkeletonPulseModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.45 : 0.85)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func skeletonPulse() -> some View {
        self.modifier(SkeletonPulseModifier())
    }
}
