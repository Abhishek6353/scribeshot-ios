import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @State private var showFullScreenImage = false
    @Environment(\.dismiss) private var dismiss

    init(item: ScreenshotItem) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(item: item))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                screenshotSection
                aiSection
                tagsSection
                notesSection
                metadataSection
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.saveChanges()
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadFullImage()
        }
    }

    private var screenshotSection: some View {
        Group {
            if let image = viewModel.fullImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
        }
    }

    private var aiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI Generated", systemImage: "sparkles")
                .font(.caption)
                .foregroundStyle(.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text("Title")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Title", text: $viewModel.title)
                    .font(.headline)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Summary")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $viewModel.summary)
                    .font(.subheadline)
                    .frame(minHeight: 60)
                    .padding(10)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(.secondary)

            TagChipView(tags: $viewModel.tags, onDelete: { tag in
                viewModel.removeTag(tag)
            })

            HStack {
                TextField("Add tag...", text: $viewModel.newTagText)
                    .font(.subheadline)
                    .textFieldStyle(.plain)

                Button("Add") {
                    viewModel.addTag()
                }
                .font(.subheadline)
                .disabled(viewModel.newTagText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }


    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $viewModel.notes)
                .font(.subheadline)
                .frame(minHeight: 80)
                .padding(10)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 4) {
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
    }
}
