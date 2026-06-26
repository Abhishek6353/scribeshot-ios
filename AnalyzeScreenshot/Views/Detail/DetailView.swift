import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var showFullScreenImage = false
    @Environment(\.dismiss) private var dismiss

    init(item: ScreenshotItem) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(item: item))
    }

    var body: some View {
        Form {
            Section {
                screenshotSection
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section(header: Label("AI Analysis", systemImage: "sparkles")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Title", text: $viewModel.title)
                        .font(.body)
                }
                .padding(.vertical, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Summary")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.summary)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 2)
            }

            Section(header: Text("Tags")) {
                if !viewModel.tags.isEmpty {
                    TagChipView(tags: $viewModel.tags, onDelete: { tag in
                        viewModel.removeTag(tag)
                    })
                    .padding(.vertical, 4)
                }

                HStack {
                    TextField("Add tag...", text: $viewModel.newTagText)
                        .font(.body)
                        .textFieldStyle(.plain)

                    if !viewModel.newTagText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button("Add") {
                            viewModel.addTag()
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                    }
                }
            }

            Section(header: Text("Notes")) {
                ZStack(alignment: .topLeading) {
                    if viewModel.notes.isEmpty {
                        Text("Add personal notes...")
                            .font(.body)
                            .foregroundColor(Color(.placeholderText))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $viewModel.notes)
                        .font(.body)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                }
            }

            Section {
                metadataSection
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.saveChanges()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .task {
            await viewModel.loadFullImage()
        }
    }

    private var screenshotSection: some View {
        HStack {
            Spacer()
            if let image = viewModel.fullImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .onTapGesture {
                        showFullScreenImage = true
                    }
                    .fullScreenCover(isPresented: $showFullScreenImage) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .background(Color.black)
                                .ignoresSafeArea()

                            Button {
                                showFullScreenImage = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .padding(16)
                            }
                        }
                        .background(Color.black)
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
                    .frame(height: 200)
                    .overlay {
                        ProgressView()
                    }
            }
            Spacer()
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .center, spacing: 4) {
            if !viewModel.sourceApp.isEmpty, viewModel.sourceApp != "Unknown" {
                Label(viewModel.sourceApp, systemImage: "app.badge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Created: \(viewModel.createdAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let processed = viewModel.processedAt {
                Text("Processed: \(processed.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
