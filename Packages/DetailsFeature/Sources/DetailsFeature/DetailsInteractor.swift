import DomainKit

@MainActor
final class DetailsInteractor: DetailsInteractorInput {
    private let refreshHook: RefreshSelectedUniversity

    init(refresh: @escaping RefreshSelectedUniversity) {
        self.refreshHook = refresh
    }

    func refresh() async throws -> University? {
        try await refreshHook()
    }
}
