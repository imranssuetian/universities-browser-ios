import Foundation
import NetworkKit
import DomainKit

struct UniversityRemoteDataSource: Sendable {
    private let api: APIClient
    private let baseURL: URL

    init(
        api: APIClient = APIClient(),
        baseURL: URL = URL(string: "http://universities.hipolabs.com")!
    ) {
        self.api = api
        self.baseURL = baseURL
    }

    func universities(country: String) async throws -> [University] {
        let endpoint = Endpoint(
            baseURL: baseURL,
            path: "search",
            queryItems: [URLQueryItem(name: "country", value: country)]
        )
        let dtos: [UniversityDTO] = try await api.request(endpoint)
        return dtos.map(\.domainModel)
    }
}
