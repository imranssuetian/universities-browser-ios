import Foundation

public protocol FetchUniversitiesUseCase: Sendable {

    func load(country: String) async throws -> [University]

    func refresh(country: String) async throws -> [University]
}

public struct DefaultFetchUniversitiesUseCase: FetchUniversitiesUseCase {

    private let repository: UniversityRepository

    public init(repository: UniversityRepository) {
        self.repository = repository
    }

    public func load(country: String) async throws -> [University] {
        do {
            return try await repository.refreshUniversities(country: country)
        } catch {
            let cached = try await repository.cachedUniversities(country: country)
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    public func refresh(country: String) async throws -> [University] {
        try await repository.refreshUniversities(country: country)
    }
}
