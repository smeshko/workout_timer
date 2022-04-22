import CoreData
import Combine

public enum CoreDataError: Error {
    case failedUpdatingContext
    case noChangesPending
    case objectNotFound
}

protocol DatabaseClientProtocol {
    func insert<T: DomainEntity>(_ object: T) async throws -> T
    func delete<T: DomainEntity>(_ object: T) async throws -> String
    func fetchAll<T: DomainEntity>(_ type: T.Type) async throws -> [T]
    func update<T: DomainEntity>(_ object: T) async throws -> T.EntityObject.Entity
}

struct CoreDataClient: DatabaseClientProtocol {
    static let shared = CoreDataClient()

    static var preview: CoreDataClient = {
        let result = CoreDataClient(inMemory: true)
        let viewContext = result.container.viewContext

        let mock1 = QuickWorkoutSegmentDao(context: viewContext)
        mock1.id = UUID()
        mock1.sets = 2
        mock1.work = 40
        mock1.pause = 20

        let mock2 = QuickWorkoutSegmentDao(context: viewContext)
        mock2.id = UUID()
        mock2.sets = 4
        mock2.work = 60
        mock2.pause = 20

        let mock3 = QuickWorkoutSegmentDao(context: viewContext)
        mock3.id = UUID()
        mock3.sets = 10
        mock3.work = 30
        mock3.pause = 10

        let mock4 = QuickWorkoutSegmentDao(context: viewContext)
        mock4.id = UUID()
        mock4.sets = 8
        mock4.work = 60
        mock4.pause = 40

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    private let container: NSPersistentCloudKitContainer
    private var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "WorkoutTimer", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {

            fatalError("Unable to instantiate managed object model")
        }

        container = NSPersistentCloudKitContainer(name: "WorkoutTimer", managedObjectModel: managedObjectModel)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { [container] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
    }

    func fetchAll<T: DomainEntity>(_ type: T.Type) async throws -> [T] {
        let request = T.EntityObject.fetchRequest()
        let dateSort = NSSortDescriptor(key: "createdAt", ascending: false)

        request.sortDescriptors = [dateSort]
        let result = try container.viewContext.fetch(request)

        guard let items = result as? [T.EntityObject] else {
            throw CoreDataError.objectNotFound
        }
        return items.compactMap { $0.toDomainEntity() as? T }
    }

    func fetch<T: DomainEntity>(with predicate: NSPredicate) async throws -> [T] {
        let request = T.EntityObject.fetchRequest()
        request.predicate = predicate
        let result = try container.viewContext.fetch(request)

        guard let items = result as? [T.EntityObject] else {
            throw CoreDataError.objectNotFound
        }
        return items.compactMap { $0.toDomainEntity() as? T }
    }

    func insert<T: DomainEntity>(_ object: T) async throws -> T {
        let _ = object.createDatabaseEntity(in: viewContext)
        return try await saveContext(successObject: object)
    }

    func update<T: DomainEntity>(_ object: T) async throws -> T.EntityObject.Entity {
        let request = T.EntityObject.fetchRequest()
        let predicate = NSPredicate(format: "id = %@", object.objectId)
        request.predicate = predicate

        let result = try container.viewContext.fetch(request)
        guard result.count == 1, let managedObject = result.first as? T.EntityObject else {
            throw CoreDataError.objectNotFound
        }

        if let new = object as? T.EntityObject.Entity {
            managedObject.update(with: new, in: viewContext)
        }
        return try await saveContext(successObject: managedObject.toDomainEntity())
    }

    func delete<T: DomainEntity>(_ object: T) async throws -> String {
        let request = T.EntityObject.fetchRequest()
        let predicate = NSPredicate(format: "id = %@", object.objectId)
        request.predicate = predicate

        let result = try container.viewContext.fetch(request)
        guard result.count == 1, let managedObject = result.first as? NSManagedObject else {
            throw CoreDataError.objectNotFound
        }
        container.viewContext.delete(managedObject)
        return try await saveContext(successObject: object.objectId)
    }
}

private extension CoreDataClient {
    func saveContext<T>(successObject: T) async throws -> T {
        guard viewContext.hasChanges else {
            throw CoreDataError.noChangesPending
        }
        try viewContext.save()
        return successObject
    }
}
