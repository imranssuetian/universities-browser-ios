import DomainKit

final class ListingInteractor: ListingInteractorInput {
    private let useCase: FetchUniversitiesUseCase
    private let country: String

    init(useCase: FetchUniversitiesUseCase, country: String) {
        self.useCase = useCase
        self.country = country
    }

    func loadUniversities() async throws -> [University] {
        try await useCase.load(country: country)
    }

    func refreshUniversities() async throws -> [University] {
        try await useCase.refresh(country: country)
    }
}
