import XCTest
import DomainKit
@testable import PersistenceKit

final class CoreDataUniversityCacheTests: XCTestCase {

    private let country = "United Arab Emirates"

    private func makeSUT() -> CoreDataUniversityCache {
        CoreDataUniversityCache(inMemory: true)
    }

    func test_load_returnsEmpty_whenNothingCached() async throws {
        let sut = makeSUT()
        let result = try await sut.load(country: country)
        XCTAssertEqual(result, [])
    }

    func test_replace_thenLoad_roundTripsAllFields() async throws {
        let sut = makeSUT()
        let university = University(
            name: "United Arab Emirates University",
            country: country,
            alphaTwoCode: "AE",
            stateProvince: "Abu Dhabi",
            domains: ["uaeu.ac.ae"],
            webPages: ["https://www.uaeu.ac.ae/"]
        )

        try await sut.replace([university], country: country)
        let loaded = try await sut.load(country: country)

        XCTAssertEqual(loaded, [university])
    }

    func test_replace_overwritesPreviousCacheForSameCountry() async throws {
        let sut = makeSUT()
        try await sut.replace([University(name: "Old", country: country)], country: country)
        try await sut.replace([University(name: "New", country: country)], country: country)

        let loaded = try await sut.load(country: country)

        XCTAssertEqual(loaded.map(\.name), ["New"])
    }

    func test_load_isScopedByCountry() async throws {
        let sut = makeSUT()
        try await sut.replace([University(name: "UAEU", country: country)], country: country)
        try await sut.replace([University(name: "MIT", country: "United States")], country: "United States")

        let uae = try await sut.load(country: country)

        XCTAssertEqual(uae.map(\.name), ["UAEU"])
    }

    func test_load_sortsByName() async throws {
        let sut = makeSUT()
        let universities = ["Zayed", "Abu Dhabi", "Manipal"].map {
            University(name: $0, country: country)
        }
        try await sut.replace(universities, country: country)

        let loaded = try await sut.load(country: country)

        XCTAssertEqual(loaded.map(\.name), ["Abu Dhabi", "Manipal", "Zayed"])
    }
}
