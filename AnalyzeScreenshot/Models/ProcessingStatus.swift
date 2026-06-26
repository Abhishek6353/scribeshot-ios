import Foundation

enum ProcessingStatus: String, Codable {
    case pending
    case ocrInProgress
    case ocrComplete
    case aiProcessing
    case complete
    case failed
}
