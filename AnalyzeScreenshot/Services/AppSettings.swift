import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var apiKey: String = "" {
        didSet { KeychainHelper.shared.save(apiKey, forKey: "openai_api_key") }
    }
    @Published var selectedModel: OpenAIModel = .gpt4oMini {
        didSet { UserDefaults.standard.set(selectedModel.rawValue, forKey: "selected_model") }
    }
    @Published var isOnboarded: Bool = false {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "is_onboarded") }
    }

    var isConfigured: Bool { !apiKey.isEmpty }

    private init() {
        // Try reading from Keychain first
        if let storedKey = KeychainHelper.shared.read(forKey: "openai_api_key") {
            apiKey = storedKey
        } else {
            // Check if there was an old key stored in plaintext UserDefaults
            if let oldKey = UserDefaults.standard.string(forKey: "openai_api_key") {
                apiKey = oldKey
                // Securely migrate to Keychain
                KeychainHelper.shared.save(oldKey, forKey: "openai_api_key")
                // Remove the plaintext key from UserDefaults
                UserDefaults.standard.removeObject(forKey: "openai_api_key")
            } else {
                apiKey = Constants.openAIAPIKey
            }
        }
        if let raw = UserDefaults.standard.string(forKey: "selected_model"),
           let model = OpenAIModel(rawValue: raw) {
            selectedModel = model
        }
        isOnboarded = UserDefaults.standard.bool(forKey: "is_onboarded")
    }
}
