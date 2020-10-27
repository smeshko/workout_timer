import CoreData
import Combine

public enum CoreDataError: Error {
    case failedUpdatingContext
    case noChangesPending
    case objectNotFound
}

struct CoreDataClient {
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
        guard let persistenceBundle = Bundle(identifier: "com.tsonev.mobile.ios.CorePersistence"),
              let modelURL = persistenceBundle.url(forResource: "WorkoutTimer", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {

            fatalError("Unable to instantiate managed object model")
        }

        container = NSPersistentCloudKitContainer(name: "WorkoutTimer", managedObjectModel: managedObjectModel)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func fetchAll<T: DomainEntity>(_ type: T.Type) -> Future<[T], CoreDataError> {
        Future { promise in
            let request = T.EntityObject.fetchRequest()
            let dateSort = NSSortDescriptor(key: "createdAt", ascending:false)

            request.sortDescriptors = [dateSort]

            do {
                let result = try container.viewContext.fetch(request)
                guard let items = result as? [T.EntityObject] else {
                    promise(.failure(.objectNotFound))
                    return
                }
                promise(.success(items.compactMap({ $0.toDomainEntity() as? T })))
            } catch {
                promise(.failure(.failedUpdatingContext))
            }
        }

    }

    func fetch<T: DomainEntity>(with predicate: NSPredicate) -> Future<[T], CoreDataError> {
        Future { promise in
            let request = T.EntityObject.fetchRequest()
            request.predicate = predicate

            do {
                let result = try container.viewContext.fetch(request)
                guard let items = result as? [T.EntityObject] else {
                    promise(.failure(.objectNotFound))
                    return
                }
                promise(.success(items.compactMap({ $0.toDomainEntity() as? T })))
            } catch {
                promise(.failure(.failedUpdatingContext))
            }
        }
    }

    func insert<T: DomainEntity>(_ object: T) -> Future<T, CoreDataError> {
        Future { promise in
            let _ = object.createDatabaseEntity(in: viewContext)
            saveContext(promise: promise, successObject: object)
        }
    }

    func delete<T: DomainEntity>(_ object: T) -> Future<String, CoreDataError> {
        Future { promise in
            let request = T.EntityObject.fetchRequest()
            let predicate = NSPredicate(format: "id = %@", object.objectId)
            request.predicate = predicate

            do {
                let result = try container.viewContext.fetch(request)
                guard result.count == 1, let managedObject = result.first as? NSManagedObject else {
                    promise(.failure(.objectNotFound))
                    return
                }
                container.viewContext.delete(managedObject)
                saveContext(promise: promise, successObject: object.objectId)
            } catch {
                promise(.failure(.failedUpdatingContext))
            }
        }
    }
}

private extension CoreDataClient {
    func saveContext<T>(promise: (Result<T, CoreDataError>) -> Void, successObject: T) {
        guard viewContext.hasChanges else {
            promise(.failure(.noChangesPending))
            return
        }
        do {
            try viewContext.save()
            promise(.success(successObject))
        } catch {
            promise(.failure(.failedUpdatingContext))
        }
    }
}
