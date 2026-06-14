import CoreData
import DomainKit

enum CacheMapper {

    private static let separator = "\n"

    static func populate(_ object: NSManagedObject, from university: University) {
        object.setValue(university.name, forKey: "name")
        object.setValue(university.country, forKey: "country")
        object.setValue(university.alphaTwoCode, forKey: "alphaTwoCode")
        object.setValue(university.stateProvince, forKey: "stateProvince")
        object.setValue(encode(university.domains), forKey: "domains")
        object.setValue(encode(university.webPages), forKey: "webPages")
    }

    static func university(from object: NSManagedObject) -> University? {
        guard
            let name = object.value(forKey: "name") as? String,
            let country = object.value(forKey: "country") as? String
        else { return nil }

        return University(
            name: name,
            country: country,
            alphaTwoCode: object.value(forKey: "alphaTwoCode") as? String,
            stateProvince: object.value(forKey: "stateProvince") as? String,
            domains: decode(object.value(forKey: "domains") as? String),
            webPages: decode(object.value(forKey: "webPages") as? String)
        )
    }

    private static func encode(_ values: [String]) -> String {
        values.joined(separator: separator)
    }

    private static func decode(_ raw: String?) -> [String] {
        guard let raw, !raw.isEmpty else { return [] }
        return raw.components(separatedBy: separator)
    }
}
