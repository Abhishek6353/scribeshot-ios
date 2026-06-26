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
    @Published var lastError: Error? = nil

    private let ocrService = OCRService.shared
    private let openAIService = OpenAIService.shared
    private let photoService = PhotoLibraryService.shared
    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func processNewScreenshots() async {
        guard !isProcessing else { return }
        
        let settings = AppSettings.shared
        guard settings.isConfigured else { return }

        isProcessing = true
        lastError = nil
        defer { isProcessing = false }

        guard let modelContext = modelContext else { return }

        // 1. Cleanup deleted screenshots
        let fetchDescriptor = FetchDescriptor<ScreenshotItem>()
        let existingItems = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let existingIdentifiers = existingItems.map(\.localIdentifier)

        if !existingIdentifiers.isEmpty {
            let foundAssets = PHAsset.fetchAssets(withLocalIdentifiers: existingIdentifiers, options: nil)
            var activeIdentifiers = Set<String>()
            foundAssets.enumerateObjects { asset, _, _ in
                activeIdentifiers.insert(asset.localIdentifier)
            }

            for item in existingItems {
                if !activeIdentifiers.contains(item.localIdentifier) {
                    modelContext.delete(item)
                }
            }
            try? modelContext.save()
        }

        // 2. Fetch recent screenshots and find new ones to process
        let updatedExistingItems = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let updatedIdentifiers = Set(updatedExistingItems.map(\.localIdentifier))

        let fetchResult = photoService.fetchRecentScreenshots(limit: 100)
        var newAssets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            if !updatedIdentifiers.contains(asset.localIdentifier) {
                newAssets.append(asset)
            }
        }

        // 3. Find incomplete items to re-process
        let incompleteItems = updatedExistingItems.filter { $0.processingStatus != .complete }
        let incompleteIdentifiers = incompleteItems.map(\.localIdentifier)
        var incompleteAssetsMap = [String: PHAsset]()
        if !incompleteIdentifiers.isEmpty {
            let incompleteAssetsResult = PHAsset.fetchAssets(withLocalIdentifiers: incompleteIdentifiers, options: nil)
            incompleteAssetsResult.enumerateObjects { asset, _, _ in
                incompleteAssetsMap[asset.localIdentifier] = asset
            }
        }

        pendingCount = newAssets.count + incompleteItems.count

        // Process incomplete items first
        for item in incompleteItems {
            guard lastError == nil else { break }
            if let asset = incompleteAssetsMap[item.localIdentifier] {
                await process(asset: asset, item: item, modelContext: modelContext)
            } else {
                modelContext.delete(item)
            }
        }

        // Process new items
        for asset in newAssets {
            guard lastError == nil else { break }
            await process(asset: asset, modelContext: modelContext)
        }

        pendingCount = 0
    }

    private func process(asset: PHAsset, item: ScreenshotItem? = nil, modelContext: ModelContext) async {
        let activeItem: ScreenshotItem
        if let item = item {
            activeItem = item
        } else {
            activeItem = ScreenshotItem(localIdentifier: asset.localIdentifier)
            modelContext.insert(activeItem)
        }

        // If OCR was already done but AI failed/was skipped, proceed directly to AI processing
        if activeItem.processingStatus == .ocrComplete && !activeItem.rawOCRText.isEmpty {
            await runAIProcessing(for: activeItem, modelContext: modelContext)
            return
        }

        activeItem.processingStatus = .ocrInProgress

        guard let image = await photoService.requestFullImage(for: asset) else {
            activeItem.processingStatus = .failed
            return
        }

        do {
            let ocrText = try await ocrService.extractText(from: image)
            activeItem.rawOCRText = ocrText
            let sourceApp = await ocrService.extractSourceApp(from: ocrText)
            activeItem.sourceApp = sourceApp
            activeItem.processingStatus = .ocrComplete

            let cleanedText = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedText.isEmpty {
                activeItem.title = (!sourceApp.isEmpty && sourceApp != "Unknown") ? "Screenshot (\(sourceApp))" : "Screenshot"
                activeItem.summary = "No text was detected in this screenshot."
                activeItem.tags = []
                activeItem.processedAt = .now
                activeItem.processingStatus = .complete
                try? modelContext.save()
                return
            }
        } catch {
            activeItem.processingStatus = .failed
            return
        }

        await runAIProcessing(for: activeItem, modelContext: modelContext)
    }

    private func runAIProcessing(for item: ScreenshotItem, modelContext: ModelContext) async {
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
            lastError = error
        }
    }
}
