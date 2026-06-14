import Foundation

public struct APIClient: Sendable {
    private let client: HTTPClient
    private let decoder: JSONDecoder
    private let acceptableStatusCodes: Range<Int>

    public init(
        client: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = JSONDecoder(),
        acceptableStatusCodes: Range<Int> = 200..<300
    ) {
        self.client = client
        self.decoder = decoder
        self.acceptableStatusCodes = acceptableStatusCodes
    }

    public func request<Response: Decodable>(
        _ endpoint: Endpoint,
        as type: Response.Type = Response.self
    ) async throws -> Response {
        let urlRequest = try endpoint.makeURLRequest()
        let (data, response) = try await client.data(for: urlRequest)

        guard acceptableStatusCodes.contains(response.statusCode) else {
            throw NetworkError.unacceptableStatusCode(response.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding(String(describing: error))
        }
    }
}
