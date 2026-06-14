import Foundation
import DomainKit

@MainActor
final class DetailsPresenter: ObservableObject {

    @Published private(set) var university: University
    @Published private(set) var isRefreshing = false

    @Published var refreshError: String?

    private let interactor: DetailsInteractorInput

    init(university: University, interactor: DetailsInteractorInput) {
        self.university = university
        self.interactor = interactor
    }

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true
        Task {
            defer { isRefreshing = false }
            do {
                if let updated = try await interactor.refresh() {
                    university = updated
                }
            } catch {
                refreshError = "We couldn't refresh right now. Please try again."
            }
        }
    }
}
