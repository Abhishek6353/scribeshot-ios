import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \ScreenshotItem.createdAt, order: .reverse) private var screenshotItems: [ScreenshotItem]
    @StateObject private var viewModel = HomeViewModel()
    @State private var processingTask: Task<Void, Never>?
    @State private var hasAppeared = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                if screenshotItems.isEmpty {
                    EmptyStateView(showingSettings: $showingSettings)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredItems(screenshotItems)) { item in
                                NavigationLink(destination: DetailView(item: item)) {
                                    ScreenshotCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Screenshots")
            .searchable(text: $viewModel.searchText, prompt: "Search screenshots...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            processingTask?.cancel()
                            processingTask = Task {
                                viewModel.isProcessing = true
                                await viewModel.refresh(screenshotItems: screenshotItems)
                                viewModel.isProcessing = false
                            }
                        } label: {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(viewModel.isProcessing)

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.pendingCount > 0 {
                        Text("\(viewModel.pendingCount) processing...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("API Key Required", isPresented: $viewModel.showingAPIAlert) {
                Button("Open Settings") {
                    showingSettings = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Configure your OpenAI API key in Settings to enable AI-powered summaries and tags.")
            }
            .alert("Processing Error", isPresented: Binding(
                get: { viewModel.processingError != nil },
                set: { if !$0 { viewModel.processingError = nil } }
            )) {
                Button("Open Settings") {
                    showingSettings = true
                }
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.processingError {
                    Text(error.localizedDescription)
                }
            }
            .sheet(isPresented: $showingSettings, onDismiss: {
                processingTask?.cancel()
                processingTask = Task {
                    viewModel.isProcessing = true
                    await viewModel.refresh(screenshotItems: screenshotItems)
                    viewModel.isProcessing = false
                }
            }) {
                SettingsView()
            }
            .overlay {
                if viewModel.isProcessing && !screenshotItems.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            ProgressView()
                            Text("Processing screenshots...")
                                .font(.caption)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom, 16)
                    }
                }
            }
            .task {
                guard !hasAppeared else { return }
                hasAppeared = true
                processingTask?.cancel()
                processingTask = Task {
                    viewModel.isProcessing = true
                    await viewModel.refresh(screenshotItems: screenshotItems)
                    viewModel.isProcessing = false
                }
            }
            .onReceive(PhotoLibraryService.shared.$newScreenshotIdentifiers) { _ in
                guard hasAppeared else { return }
                processingTask?.cancel()
                processingTask = Task {
                    viewModel.isProcessing = true
                    await viewModel.refresh(screenshotItems: screenshotItems)
                    viewModel.isProcessing = false
                }
            }
        }
    }
}
