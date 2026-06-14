import XCTest
import DomainKit
@testable import DetailsFeature

@MainActor
final class DetailsPresenterTests: XCTestCase {

    private let university = University(name: "UAEU", country: "United Arab Emirates")

    func test_init_holdsPassedUniversity_withoutRefreshing() {
        let sut = DetailsPresenter(university: university, interactor: SpyInteractor(result: .success(nil)))

        XCTAssertEqual(sut.university, university)
        XCTAssertFalse(sut.isRefreshing)
    }

    func test_refresh_updatesUniversity_whenHookReturnsUpdatedItem() async {
        let updated = University(name: "UAEU", country: "United Arab Emirates", alphaTwoCode: "AE")
        let sut = DetailsPresenter(university: university, interactor: SpyInteractor(result: .success(updated)))

        sut.refresh()
        await settle(sut)

        XCTAssertEqual(sut.university, updated)
        XCTAssertFalse(sut.isRefreshing)
        XCTAssertNil(sut.refreshError)
    }

    func test_refresh_keepsExistingUniversity_whenHookReturnsNil() async {
        let sut = DetailsPresenter(university: university, interactor: SpyInteractor(result: .success(nil)))

        sut.refresh()
        await settle(sut)

        XCTAssertEqual(sut.university, university)
    }

    func test_refresh_setsError_whenHookThrows() async {
        let sut = DetailsPresenter(university: university, interactor: SpyInteractor(result: .failure(AnyError())))

        sut.refresh()
        await settle(sut)

        XCTAssertNotNil(sut.refreshError)
        XCTAssertEqual(sut.university, university)
    }

    func test_refresh_ignoresReentrantTaps() async {
        let interactor = SpyInteractor(result: .success(nil))
        let sut = DetailsPresenter(university: university, interactor: interactor)

        sut.refresh()
        sut.refresh()
        await settle(sut)

        XCTAssertEqual(interactor.callCount, 1)
    }

    private func settle(_ presenter: DetailsPresenter) async {
        for _ in 0..<200 where presenter.isRefreshing {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }
}

private struct AnyError: Error {}

@MainActor
private final class SpyInteractor: DetailsInteractorInput {
    let result: Result<University?, Error>
    private(set) var callCount = 0

    init(result: Result<University?, Error>) {
        self.result = result
    }

    func refresh() async throws -> University? {
        callCount += 1

        await Task.yield()
        return try result.get()
    }
}
