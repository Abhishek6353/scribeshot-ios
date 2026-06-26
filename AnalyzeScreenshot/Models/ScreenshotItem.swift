import Foundation
import SwiftData

@Model
class ScreenshotItem {
    var localIdentifier: String
    var title: String
    var summary: String
    var tags: [String]
    var rawOCRText: String
    var notes: String
    var sourceApp: String
    var createdAt: Date
    var processedAt: Date?
    var processingStatusRaw: String

    var processingStatus: ProcessingStatus {
        get { ProcessingStatus(rawValue: processingStatusRaw) ?? .pending }
        set { processingStatusRaw = newValue.rawValue }
    }

    init(
        localIdentifier: String,
        title: String = "",
        summary: String = "",
        tags: [String] = [],
        rawOCRText: String = "",
        notes: String = "",
        sourceApp: String = "",
        createdAt: Date = .now,
        processedAt: Date? = nil,
        processingStatus: ProcessingStatus = .pending
    ) {
        self.localIdentifier = localIdentifier
        self.title = title
        self.summary = summary
        self.tags = tags
        self.rawOCRText = rawOCRText
        self.notes = notes
        self.sourceApp = sourceApp
        self.createdAt = createdAt
        self.processedAt = processedAt
        self.processingStatusRaw = processingStatus.rawValue
    }
}
