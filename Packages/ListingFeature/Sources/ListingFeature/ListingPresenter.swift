import Foundation
import DomainKit

@MainActor
final class ListingPresenter: ObservableObject {

    @Published private(set) var state: ListingViewState = .loading

    private let interactor: ListingInteractorInput
    private let router: ListingRouting

    private var universities: [University] = []
    private var hasStarted = false

    init(interactor: ListingInteractorInput, router: ListingRouting) {
        self.interactor = interactor
        self.router = router
    }

    func onAppear() {
        guard !hasStarted else { return }
        hasStarted = true
        load()
    }

    func retry() {
        load()
    }

    func didSelect(_ university: University) {
        router.showDetails(for: university, refresh: makeRefreshHook(for: university))
    }

    private func load() {
        state = .loading
        Task {
            do {
                apply(try await interactor.loadUniversities())
            } catch {
                state = .error(message: Self.errorMessage(for: error))
            }
        }
    }

    private func apply(_ universities: [University]) {
        self.universities = universities
        state = universities.isEmpty ? .empty : .loaded(universities)
    }

    private func makeRefreshHook(for selected: University) -> RefreshSelectedUniversity {
        { [weak self] in
            guard let self else { return nil }
            let refreshed = try await self.interactor.refreshUniversities()
            self.apply(refreshed)
            return refreshed.first { $0.id == selected.id }
        }
    }

    private static func errorMessage(for error: Error) -> String {
        "We couldn't load the universities. Please check your connection and try again."
    }
}
