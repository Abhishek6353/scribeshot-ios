import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var isProcessing = false
    @Published var pendingCount = 0
    @Published var showingAPIAlert = false
    @Published var processingError: Error? = nil {
        didSet {
            if processingError == nil && processingQueue.lastError != nil {
                processingQueue.lastError = nil
            }
        }
    }

    private let processingQueue = ProcessingQueue.shared
    private let photoService = PhotoLibraryService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        processingQueue.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.processingError = error
            }
            .store(in: &cancellables)
    }

    func refresh(screenshotItems: [ScreenshotItem]) async {
        let settings = AppSettings.shared
        guard settings.isConfigured else {
            showingAPIAlert = true
            return
        }

        let unprocessed = screenshotItems.filter { $0.processingStatus == .pending }
        guard !unprocessed.isEmpty else {
            await processingQueue.processNewScreenshots()
            return
        }

        await processingQueue.processNewScreenshots()
    }

    var hasFilteredResults: Bool {
        !searchText.isEmpty
    }

    func filteredItems(_ items: [ScreenshotItem]) -> [ScreenshotItem] {
        guard !searchText.isEmpty else { return items }
        let query = searchText.lowercased()
        return items.filter { item in
            item.title.lowercased().contains(query) ||
            item.summary.lowercased().contains(query) ||
            item.tags.contains { $0.lowercased().contains(query) } ||
            item.rawOCRText.lowercased().contains(query)
        }
    }
}
