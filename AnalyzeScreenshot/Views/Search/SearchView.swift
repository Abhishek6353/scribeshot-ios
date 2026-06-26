import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \ScreenshotItem.createdAt, order: .reverse) private var allItems: [ScreenshotItem]
    @Binding var searchText: String

    var results: [ScreenshotItem] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return allItems.filter { item in
            item.title.lowercased().contains(query) ||
            item.summary.lowercased().contains(query) ||
            item.tags.contains { $0.lowercased().contains(query) } ||
            item.rawOCRText.lowercased().contains(query)
        }
    }

    var body: some View {
        if results.isEmpty && !searchText.isEmpty {
            ContentUnavailableView(
                "No Results",
                systemImage: "magnifyingglass",
                description: Text("Try a different search term")
            )
        } else if !searchText.isEmpty {
            List(results) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title.isEmpty ? "Untitled" : item.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if !item.summary.isEmpty {
                            Text(item.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
