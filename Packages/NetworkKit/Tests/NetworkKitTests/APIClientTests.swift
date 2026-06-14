import XCTest
@testable import NetworkKit

final class APIClientTests: XCTestCase {

    private let endpoint = Endpoint(
        baseURL: URL(string: "https://example.com")!,
        path: "search",
        queryItems: [URLQueryItem(name: "country", value: "United Arab Emirates")]
    )

    func test_request_buildsURLWithEncodedQuery() async throws {
        let stub = StubHTTPClient(result: .success((Data("[]".utf8), 200)))
        let sut = APIClient(client: stub)

        _ = try await sut.request(endpoint, as: [String].self)

        XCTAssertEqual(
            stub.lastRequest?.url?.absoluteString,
            "https://example.com/search?country=United%20Arab%20Emirates"
        )
    }

    func test_request_decodesSuccessfulResponse() async throws {
        let json = #"[{"name":"UAEU"}]"#
        let stub = StubHTTPClient(result: .success((Data(json.utf8), 200)))
        let sut = APIClient(client: stub)

        let decoded = try await sut.request(endpoint, as: [Item].self)

        XCTAssertEqual(decoded, [Item(name: "UAEU")])
    }

    func test_request_throwsOnUnacceptableStatus() async {
        let stub = StubHTTPClient(result: .success((Data(), 500)))
        let sut = APIClient(client: stub)

        await assertThrows(NetworkError.unacceptableStatusCode(500)) {
            _ = try await sut.request(endpoint, as: [Item].self)
        }
    }

    func test_request_wrapsDecodingFailure() async {
        let stub = StubHTTPClient(result: .success((Data("not json".utf8), 200)))
        let sut = APIClient(client: stub)

        do {
            _ = try await sut.request(endpoint, as: [Item].self)
            XCTFail("Expected decoding error")
        } catch let error as NetworkError {
            if case .decoding = error { return }
            XCTFail("Expected .decoding, got \(error)")
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    private struct Item: Decodable, Equatable { let name: String }

    private func assertThrows(
        _ expected: NetworkError,
        _ operation: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await operation()
            XCTFail("Expected to throw \(expected)", file: file, line: line)
        } catch let error as NetworkError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected NetworkError, got \(error)", file: file, line: line)
        }
    }
}

private final class StubHTTPClient: HTTPClient, @unchecked Sendable {
    let result: Result<(Data, Int), Error>
    private(set) var lastRequest: URLRequest?

    init(result: Result<(Data, Int), Error>) {
        self.result = result
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lastRequest = request
        let (data, status) = try result.get()
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}
