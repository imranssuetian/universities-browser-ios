import SwiftUI

public struct LoadingStateView: View {
    private let rowCount: Int

    public init(rowCount: Int = 8) {
        self.rowCount = rowCount
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rowCount, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 160, height: 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .shimmering()
        .accessibilityLabel("Loading universities")
    }
}
