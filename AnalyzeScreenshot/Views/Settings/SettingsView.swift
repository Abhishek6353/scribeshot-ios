import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isVerifying = false
    @State private var validationResult: Result<Void, Error>?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("OpenAI Integration")) {
                    HStack {
                        Text("API Key")
                            .foregroundColor(.primary)
                        Spacer()
                        SecureField("Required", text: $settings.apiKey)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onChange(of: settings.apiKey) { _, _ in
                                validationResult = nil
                            }
                    }

                    VStack(alignment: .leading, spacing: 6) {
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
                    }
                    .padding(.vertical, 4)

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
            .alert("Verification Failed", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
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
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isVerifying = false
        }
    }
}
