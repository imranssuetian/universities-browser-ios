import CoreData
import DomainKit

public protocol UniversityCache: Sendable {

    func replace(_ universities: [University], country: String) async throws

    func load(country: String) async throws -> [University]
}

public final class CoreDataUniversityCache: UniversityCache, @unchecked Sendable {

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(inMemory: Bool = false) {
        let model = UniversityCacheModel.makeModel()
        container = NSPersistentContainer(name: "UniversityCache", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let url = Self.storeURL()
            description.url = url
        }
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError {

            assertionFailure("Failed to load persistent store: \(loadError)")
        }

        context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public func replace(_ universities: [University], country: String) async throws {
        try await context.perform { [context] in
            let deleteRequest = Self.fetchRequest(country: country)
            for object in try context.fetch(deleteRequest) {
                context.delete(object)
            }

            let entity = NSEntityDescription.entity(
                forEntityName: UniversityCacheModel.entityName,
                in: context
            )!
            for university in universities {
                let object = NSManagedObject(entity: entity, insertInto: context)
                CacheMapper.populate(object, from: university)
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func load(country: String) async throws -> [University] {
        try await context.perform { [context] in
            let request = Self.fetchRequest(country: country)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).compactMap(CacheMapper.university(from:))
        }
    }

    private static func fetchRequest(country: String) -> NSFetchRequest<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: UniversityCacheModel.entityName)
        request.predicate = NSPredicate(format: "country == %@", country)
        return request
    }

    private static func storeURL() -> URL {
        let directory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("UniversityCache.sqlite")
    }
}
