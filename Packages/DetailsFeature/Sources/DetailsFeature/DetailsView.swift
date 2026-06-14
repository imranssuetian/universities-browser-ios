import SwiftUI
import DomainKit

struct DetailsView: View {
    @ObservedObject var presenter: DetailsPresenter

    var body: some View {
        List {
            Section {
                Text(presenter.university.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Section("Location") {
                row("Country", presenter.university.country)
                if let code = presenter.university.alphaTwoCode {
                    row("Country Code", code)
                }
                if let state = presenter.university.stateProvince {
                    row("State / Province", state)
                }
            }

            if !presenter.university.domains.isEmpty {
                Section("Domains") {
                    ForEach(presenter.university.domains, id: \.self) { domain in
                        Text(domain)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if !presenter.university.webPages.isEmpty {
                Section("Web Pages") {
                    ForEach(presenter.university.webPages, id: \.self) { page in
                        if let url = URL(string: page) {
                            Link(page, destination: url)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(page)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .alert(
            "Refresh Failed",
            isPresented: Binding(
                get: { presenter.refreshError != nil },
                set: { if !$0 { presenter.refreshError = nil } }
            ),
            presenting: presenter.refreshError
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.secondary)
            Spacer(minLength: 16)
            Text(value)
                .multilineTextAlignment(.trailing)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
