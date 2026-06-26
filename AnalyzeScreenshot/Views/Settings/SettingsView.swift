import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isVerifying = false
    @State private var validationResult: Result<Void, Error>?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenAI Integration")) {
                    SecureField("API Key", text: $settings.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: settings.apiKey) { _, _ in
                            validationResult = nil
                        }

                    HStack {
                        Button {
                            verifyKey()
                        } label: {
                            HStack {
                                Text("Verify API Key")
                                    .foregroundColor((isVerifying || settings.apiKey.isEmpty) ? .secondary : .accentColor)
                                if isVerifying {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isVerifying || settings.apiKey.isEmpty)

                        if !isVerifying, let result = validationResult {
                            Spacer()
                            switch result {
                            case .success:
                                Label("Valid", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            case .failure:
                                Label("Invalid", systemImage: "exclamationmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    if let result = validationResult, case .failure(let error) = result {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                        HStack {
                            Text("Get API Key")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundColor(.secondary)
                        }
                    }

                    Picker("Model", selection: $settings.selectedModel) {
                        ForEach(OpenAIModel.allCases, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func verifyKey() {
        guard !settings.apiKey.isEmpty else { return }
        isVerifying = true
        validationResult = nil

        Task {
            do {
                try await OpenAIService.shared.validateApiKey(settings.apiKey)
                validationResult = .success(())
            } catch {
                validationResult = .failure(error)
            }
            isVerifying = false
        }
    }
}
