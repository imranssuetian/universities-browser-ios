import Foundation

public protocol UniversityRepository: Sendable {

    func refreshUniversities(country: String) async throws -> [University]

    func cachedUniversities(country: String) async throws -> [University]
}
