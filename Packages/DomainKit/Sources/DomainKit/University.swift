import Foundation

public struct University: Identifiable, Hashable, Sendable {

    public var id: String { "\(name)|\(country)" }

    public let name: String
    public let country: String
    public let alphaTwoCode: String?
    public let stateProvince: String?
    public let domains: [String]
    public let webPages: [String]

    public init(
        name: String,
        country: String,
        alphaTwoCode: String? = nil,
        stateProvince: String? = nil,
        domains: [String] = [],
        webPages: [String] = []
    ) {
        self.name = name
        self.country = country
        self.alphaTwoCode = alphaTwoCode
        self.stateProvince = stateProvince
        self.domains = domains
        self.webPages = webPages
    }
}

public extension University {

    var website: URL? {
        guard let first = webPages.first else { return nil }
        return URL(string: first)
    }
}
