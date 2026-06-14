import SwiftUI
import DomainKit
import CommonUI

struct ListingView: View {
    @ObservedObject var presenter: ListingPresenter

    var body: some View {
        content
            .onAppear { presenter.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch presenter.state {
        case .loading:
            LoadingStateView()
        case .empty:
            EmptyStateView(message: "No universities were found for this country.")
        case let .error(message):
            ErrorStateView(message: message) { presenter.retry() }
        case let .loaded(universities):
            list(universities)
        }
    }

    private func list(_ universities: [University]) -> some View {
        List(universities) { university in
            Button {
                presenter.didSelect(university)
            } label: {
                UniversityRow(university: university)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }
}

private struct UniversityRow: View {
    let university: University

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(university.name)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if let domain = university.domains.first {
                Text(domain)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
