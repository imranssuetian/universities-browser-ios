import DomainKit

@MainActor
protocol DetailsInteractorInput: AnyObject {
    func refresh() async throws -> University?
}
