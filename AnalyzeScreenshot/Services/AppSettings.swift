import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var apiKey: String = Constants.openAIAPIKey
    @Published var selectedModel: OpenAIModel = .gpt4oMini {
        didSet { UserDefaults.standard.set(selectedModel.rawValue, forKey: "selected_model") }
    }
    @Published var isOnboarded: Bool = false {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "is_onboarded") }
    }

    var isConfigured: Bool { !apiKey.isEmpty }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "selected_model"),
           let model = OpenAIModel(rawValue: raw) {
            selectedModel = model
        }
        isOnboarded = UserDefaults.standard.bool(forKey: "is_onboarded")
    }
}
