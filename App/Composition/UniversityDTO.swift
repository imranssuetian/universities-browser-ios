import Foundation
import DomainKit

struct UniversityDTO: Decodable {
    let name: String
    let country: String
    let alphaTwoCode: String?
    let stateProvince: String?
    let domains: [String]?
    let webPages: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case country
        case alphaTwoCode = "alpha_two_code"
        case stateProvince = "state-province"
        case domains
        case webPages = "web_pages"
    }
}

extension UniversityDTO {
    var domainModel: University {
        University(
            name: name,
            country: country,
            alphaTwoCode: alphaTwoCode,
            stateProvince: stateProvince,
            domains: domains ?? [],
            webPages: webPages ?? []
        )
    }
}
