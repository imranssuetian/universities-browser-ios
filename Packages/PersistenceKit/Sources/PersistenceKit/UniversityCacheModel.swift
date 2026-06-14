import CoreData

enum UniversityCacheModel {

    static let entityName = "CDUniversity"

    static func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        entity.properties = [
            attribute("name", .stringAttributeType, optional: false),
            attribute("country", .stringAttributeType, optional: false),
            attribute("alphaTwoCode", .stringAttributeType, optional: true),
            attribute("stateProvince", .stringAttributeType, optional: true),

            attribute("domains", .stringAttributeType, optional: true),
            attribute("webPages", .stringAttributeType, optional: true)
        ]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }
}
