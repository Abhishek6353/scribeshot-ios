import Foundation
import SwiftUI
import Photos
import Combine

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var title: String
    @Published var summary: String
    @Published var tags: [String]
    @Published var notes: String
    @Published var fullImage: UIImage?
    @Published var newTagText = ""

    private let original: ScreenshotItem
    private let photoService = PhotoLibraryService.shared

    var rawOCRText: String { original.rawOCRText }
    var sourceApp: String { original.sourceApp }
    var createdAt: Date { original.createdAt }
    var processedAt: Date? { original.processedAt }
    var localIdentifier: String { original.localIdentifier }

    init(item: ScreenshotItem) {
        self.original = item
        self.title = item.title
        self.summary = item.summary
        self.tags = item.tags
        self.notes = item.notes
    }

    func loadFullImage() async {
        if fullImage != nil { return }
        let assets = photoService.fetchScreenshotsFromIdentifiers([localIdentifier])
        guard let asset = assets.firstObject else { return }
        fullImage = await photoService.requestFullImage(for: asset)
    }

    func addTag() {
        let tag = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        original.tags = tags
        newTagText = ""
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        original.tags = tags
    }

    func saveChanges() {
        original.title = title
        original.summary = summary
        original.notes = notes
        original.tags = tags
    }
}
