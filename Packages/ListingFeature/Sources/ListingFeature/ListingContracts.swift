import DomainKit

protocol ListingInteractorInput: Sendable {
    func loadUniversities() async throws -> [University]
    func refreshUniversities() async throws -> [University]
}

@MainActor
protocol ListingRouting: AnyObject {
    func showDetails(for university: University, refresh: @escaping RefreshSelectedUniversity)
}
