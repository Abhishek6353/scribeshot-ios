import Foundation

struct OpenAIConfig: Codable {
    var apiKey: String
    var model: OpenAIModel

    static let defaultKey = ""
}

enum OpenAIModel: String, Codable, CaseIterable {
    case gpt4oMini = "gpt-4o-mini"
    case gpt4o = "gpt-4o"
    
    var displayName: String {
        switch self {
        case .gpt4oMini: "GPT-4o Mini (Fast, Cheap)"
        case .gpt4o: "GPT-4o (Best Quality)"
        }
    }
}
