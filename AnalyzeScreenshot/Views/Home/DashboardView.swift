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
                    EmptyStateView()
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
            .sheet(isPresented: $showingSettings) {
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
        }
    }
}
