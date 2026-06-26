import Foundation
import Vision
import UIKit

actor OCRService {
    static let shared = OCRService()

    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        return try await Task.detached(priority: .userInitiated) {
            try handler.perform([request])
            let results = request.results as? [VNRecognizedTextObservation] ?? []
            return results.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
        }.value
    }

    func extractSourceApp(from text: String) -> String {
        let text = text.lowercased()

        let sourcePatterns: [(String, String)] = [
            ("instagram.com", "Instagram"),
            ("tiktok.com", "TikTok"),
            ("amazon.com", "Amazon"),
            ("amazon.in", "Amazon"),
            ("twitter.com", "Twitter"),
            ("x.com", "X (Twitter)"),
            ("youtube.com", "YouTube"),
            ("reddit.com", "Reddit"),
            ("linkedin.com", "LinkedIn"),
            ("facebook.com", "Facebook"),
            ("netflix.com", "Netflix"),
            ("whatsapp.com", "WhatsApp"),
            ("telegram", "Telegram"),
            ("discord.com", "Discord"),
            ("notion", "Notion"),
            ("medium.com", "Medium"),
            ("substack.com", "Substack"),
            ("github.com", "GitHub"),
            ("stackoverflow.com", "Stack Overflow"),
        ]

        for (pattern, appName) in sourcePatterns {
            if text.contains(pattern) {
                return appName
            }
        }

        return "Unknown"
    }
}

enum OCRError: Error {
    case invalidImage
}
