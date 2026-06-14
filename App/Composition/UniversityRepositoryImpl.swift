import Foundation
import DomainKit
import PersistenceKit

struct UniversityRepositoryImpl: UniversityRepository {
    private let remote: UniversityRemoteDataSource
    private let cache: UniversityCache

    init(remote: UniversityRemoteDataSource, cache: UniversityCache) {
        self.remote = remote
        self.cache = cache
    }

    func refreshUniversities(country: String) async throws -> [University] {
        let universities = try await remote.universities(country: country)
        try? await cache.replace(universities, country: country)
        return universities
    }

    func cachedUniversities(country: String) async throws -> [University] {
        try await cache.load(country: country)
    }
}
