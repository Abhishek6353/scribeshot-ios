import Foundation
import SwiftData
import Photos
import UIKit
import Combine

@MainActor
final class ProcessingQueue: ObservableObject {
    static let shared = ProcessingQueue()

    @Published var pendingCount: Int = 0
    @Published var isProcessing: Bool = false

    private let ocrService = OCRService.shared
    private let openAIService = OpenAIService.shared
    private let photoService = PhotoLibraryService.shared
    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func processNewScreenshots() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        guard let modelContext = modelContext else { return }

        let fetchDescriptor = FetchDescriptor<ScreenshotItem>()
        let existingItems = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let existingIdentifiers = Set(existingItems.map(\.localIdentifier))

        let fetchResult = photoService.fetchRecentScreenshots(limit: 100)
        var newAssets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            if !existingIdentifiers.contains(asset.localIdentifier) {
                newAssets.append(asset)
            }
        }

        pendingCount = newAssets.count

        for asset in newAssets {
            await process(asset: asset, modelContext: modelContext)
        }

        pendingCount = 0
    }

    private func process(asset: PHAsset, modelContext: ModelContext) async {
        let item = ScreenshotItem(localIdentifier: asset.localIdentifier)
        modelContext.insert(item)

        item.processingStatus = .ocrInProgress

        guard let image = await photoService.requestFullImage(for: asset) else {
            item.processingStatus = .failed
            return
        }

        do {
            let ocrText = try await ocrService.extractText(from: image)
            item.rawOCRText = ocrText
            item.sourceApp = await ocrService.extractSourceApp(from: ocrText)
            item.processingStatus = .ocrComplete
        } catch {
            item.processingStatus = .failed
            return
        }

        let settings = AppSettings.shared
        guard settings.isConfigured else {
            item.processingStatus = .ocrComplete
            return
        }

        item.processingStatus = .aiProcessing

        do {
            let result = try await openAIService.contextualize(
                ocrText: item.rawOCRText,
                apiKey: settings.apiKey,
                model: settings.selectedModel
            )
            item.title = result.title
            item.summary = result.summary
            item.tags = result.tags
            item.processedAt = .now
            item.processingStatus = .complete
        } catch {
            item.processingStatus = .ocrComplete
        }
    }
}
