import Foundation

actor OpenAIService {
    static let shared = OpenAIService()

    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    private struct OpenAIRequest: Codable {
        let model: String
        let messages: [Message]
        let response_format: ResponseFormat
        let max_tokens: Int
        let temperature: Double
    }

    private struct Message: Codable {
        let role: String
        let content: String
    }

    private struct ResponseFormat: Codable {
        let type: String
    }

    private struct OpenAIResponse: Codable {
        let choices: [Choice]
    }

    private struct Choice: Codable {
        let message: Message
    }

    func contextualize(ocrText: String, apiKey: String, model: OpenAIModel) async throws -> ContextualizationResult {
        let systemPrompt = """
        You are analyzing OCR text extracted from a screenshot. Return ONLY valid JSON with these fields:
        - "title": A concise, descriptive title (max 10 words)
        - "summary": 1-2 fluent sentences describing what this screenshot is about
        - "tags": An array of 3-6 free-form tags (lowercase, hyphenated for multi-word)

        CRITICAL: Return ONLY the JSON object, no markdown, no code fences, no other text.
        """

        let userPrompt = "OCR Text:\n\(ocrText)"

        let requestBody = OpenAIRequest(
            model: model.rawValue,
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: userPrompt)
            ],
            response_format: ResponseFormat(type: "json_object"),
            max_tokens: 500,
            temperature: 0.3
        )

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(requestBody)

        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = response.choices.first?.message.content else {
            throw OpenAIError.emptyResponse
        }

        guard let resultData = content.data(using: .utf8),
              let result = try? JSONDecoder().decode(ContextualizationResult.self, from: resultData) else {
            throw OpenAIError.invalidResponseFormat(content)
        }

        return result
    }
}

struct ContextualizationResult: Codable {
    let title: String
    let summary: String
    let tags: [String]
}

enum OpenAIError: Error, LocalizedError {
    case emptyResponse
    case invalidResponseFormat(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse: "OpenAI returned an empty response"
        case .invalidResponseFormat(let content): "Failed to parse response: \(content.prefix(100))"
        case .apiError(let msg): "API error: \(msg)"
        }
    }
}
