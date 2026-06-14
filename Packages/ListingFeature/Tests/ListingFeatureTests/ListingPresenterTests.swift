import XCTest
import Combine
import DomainKit
@testable import ListingFeature

@MainActor
final class ListingPresenterTests: XCTestCase {

    private let country = "United Arab Emirates"

    func test_onAppear_loaded_publishesLoadedState() async {
        let universities = [University(name: "UAEU", country: "United Arab Emirates")]
        let (sut, _) = makeSUT(loadResult: .success(universities))

        sut.onAppear()
        await waitUntil(sut) { $0 != .loading }

        XCTAssertEqual(sut.state, .loaded(universities))
    }

    func test_onAppear_emptyResult_publishesEmptyState() async {
        let (sut, _) = makeSUT(loadResult: .success([]))

        sut.onAppear()
        await waitUntil(sut) { $0 != .loading }

        XCTAssertEqual(sut.state, .empty)
    }

    func test_onAppear_failure_publishesErrorState() async {
        let (sut, _) = makeSUT(loadResult: .failure(AnyError()))

        sut.onAppear()
        await waitUntil(sut) { $0 != .loading }

        guard case .error = sut.state else {
            return XCTFail("Expected error state, got \(sut.state)")
        }
    }

    func test_onAppear_isIdempotent() async {
        let interactor = FakeInteractor(loadResult: .success([]))
        let sut = ListingPresenter(interactor: interactor, router: SpyRouter())

        sut.onAppear()
        sut.onAppear()
        await waitUntil(sut) { $0 != .loading }

        XCTAssertEqual(interactor.loadCallCount, 1)
    }

    func test_didSelect_routesToDetails() async {
        let universities = [University(name: "UAEU", country: "United Arab Emirates")]
        let (sut, router) = makeSUT(loadResult: .success(universities))

        sut.didSelect(universities[0])

        XCTAssertEqual(router.shownUniversity, universities[0])
    }

    func test_refreshHook_updatesListAndReturnsRefreshedSelection() async throws {
        let original = University(name: "UAEU", country: "United Arab Emirates")
        let refreshed = [
            University(name: "UAEU", country: "United Arab Emirates", alphaTwoCode: "AE"),
            University(name: "Zayed University", country: "United Arab Emirates")
        ]
        let interactor = FakeInteractor(loadResult: .success([original]), refreshResult: .success(refreshed))
        let router = SpyRouter()
        let sut = ListingPresenter(interactor: interactor, router: router)

        sut.didSelect(original)
        let hook = try XCTUnwrap(router.refreshHook)
        let result = try await hook()

        XCTAssertEqual(result, refreshed[0], "Hook returns the refreshed counterpart of the selected item")
        XCTAssertEqual(sut.state, .loaded(refreshed), "List is updated as a side effect of the refresh")
    }

    private func makeSUT(
        loadResult: Result<[University], Error>
    ) -> (ListingPresenter, SpyRouter) {
        let interactor = FakeInteractor(loadResult: loadResult)
        let router = SpyRouter()
        return (ListingPresenter(interactor: interactor, router: router), router)
    }

    private func waitUntil(
        _ presenter: ListingPresenter,
        condition: @escaping (ListingViewState) -> Bool
    ) async {
        for _ in 0..<200 where !condition(presenter.state) {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }
}

private struct AnyError: Error {}

private final class FakeInteractor: ListingInteractorInput, @unchecked Sendable {
    let loadResult: Result<[University], Error>
    let refreshResult: Result<[University], Error>
    private(set) var loadCallCount = 0

    init(
        loadResult: Result<[University], Error>,
        refreshResult: Result<[University], Error> = .success([])
    ) {
        self.loadResult = loadResult
        self.refreshResult = refreshResult
    }

    func loadUniversities() async throws -> [University] {
        loadCallCount += 1
        return try loadResult.get()
    }

    func refreshUniversities() async throws -> [University] {
        try refreshResult.get()
    }
}

@MainActor
private final class SpyRouter: ListingRouting {
    private(set) var shownUniversity: University?
    private(set) var refreshHook: RefreshSelectedUniversity?

    func showDetails(for university: University, refresh: @escaping RefreshSelectedUniversity) {
        shownUniversity = university
        refreshHook = refresh
    }
}
