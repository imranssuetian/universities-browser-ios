import XCTest
@testable import DomainKit

final class FetchUniversitiesUseCaseTests: XCTestCase {

    private func makeUniversity(_ name: String) -> University {
        University(name: name, country: "United Arab Emirates")
    }

    func test_load_returnsRemote_andCachesOnSuccess() async throws {
        let remote = [makeUniversity("UAEU")]
        let repo = SpyRepository(refreshResult: .success(remote), cachedResult: .success([]))
        let sut = DefaultFetchUniversitiesUseCase(repository: repo)

        let result = try await sut.load(country: "United Arab Emirates")

        XCTAssertEqual(result, remote)
        XCTAssertEqual(repo.refreshCallCount, 1)
        XCTAssertEqual(repo.cachedCallCount, 0, "Cache should not be read when remote succeeds")
    }

    func test_load_fallsBackToCache_whenRemoteFails() async throws {
        let cached = [makeUniversity("Cached U")]
        let repo = SpyRepository(refreshResult: .failure(AnyError()), cachedResult: .success(cached))
        let sut = DefaultFetchUniversitiesUseCase(repository: repo)

        let result = try await sut.load(country: "United Arab Emirates")

        XCTAssertEqual(result, cached)
    }

    func test_load_throws_whenRemoteFailsAndCacheEmpty() async {
        let repo = SpyRepository(refreshResult: .failure(AnyError()), cachedResult: .success([]))
        let sut = DefaultFetchUniversitiesUseCase(repository: repo)

        do {
            _ = try await sut.load(country: "United Arab Emirates")
            XCTFail("Expected error to propagate")
        } catch {
            XCTAssertTrue(error is AnyError)
        }
    }

    func test_refresh_doesNotFallBackToCache_onFailure() async {
        let repo = SpyRepository(refreshResult: .failure(AnyError()), cachedResult: .success([makeUniversity("Cached")]))
        let sut = DefaultFetchUniversitiesUseCase(repository: repo)

        do {
            _ = try await sut.refresh(country: "United Arab Emirates")
            XCTFail("Refresh must surface network errors")
        } catch {
            XCTAssertEqual(repo.cachedCallCount, 0)
        }
    }
}

private struct AnyError: Error {}

private final class SpyRepository: UniversityRepository, @unchecked Sendable {
    let refreshResult: Result<[University], Error>
    let cachedResult: Result<[University], Error>
    private(set) var refreshCallCount = 0
    private(set) var cachedCallCount = 0

    init(refreshResult: Result<[University], Error>, cachedResult: Result<[University], Error>) {
        self.refreshResult = refreshResult
        self.cachedResult = cachedResult
    }

    func refreshUniversities(country: String) async throws -> [University] {
        refreshCallCount += 1
        return try refreshResult.get()
    }

    func cachedUniversities(country: String) async throws -> [University] {
        cachedCallCount += 1
        return try cachedResult.get()
    }
}
