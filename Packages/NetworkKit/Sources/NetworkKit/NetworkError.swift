import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case transport(URLError)
    case invalidResponse
    case unacceptableStatusCode(Int)
    case decoding(String)

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            return true
        case let (.transport(l), .transport(r)):
            return l.code == r.code
        case let (.unacceptableStatusCode(l), .unacceptableStatusCode(r)):
            return l == r
        case let (.decoding(l), .decoding(r)):
            return l == r
        default:
            return false
        }
    }
}
