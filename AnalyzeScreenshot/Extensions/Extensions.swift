import SwiftUI

extension Color {
    static let accentIndigo = Color(red: 0.345, green: 0.337, blue: 0.855)
    static let tagBackground = accentIndigo.opacity(0.15)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
