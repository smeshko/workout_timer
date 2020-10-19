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
        for index in 1..<10 {

            let pause = QuickTimerSegmentDao(context: viewContext)
            pause.duration = Double(index * 5)
            pause.category = 1

            let work = QuickTimerSegmentDao(context: viewContext)
            work.duration = Double(index * 10)
            work.category = 0

            let set = QuickTimerSetDao(context: viewContext)
            set.pause = pause
            set.work = work
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    private var viewContext: NSManagedObjectContext { container.viewContext }

    func insert<T: DomainEntity>(_ object: T) -> Future<T, CoreDataError> {
        Future { promise in
            let _ = object.createDatabaseEntity(in: viewContext)

            guard viewContext.hasChanges else {
                promise(.failure(.noChangesPending))
                return
            }
            do {
                try viewContext.save()
                promise(.success(object))
            } catch {
                promise(.failure(.failedUpdatingContext))
            }
        }
    }

    func delete<T: DomainEntity>(_ object: T) -> Future<Void, CoreDataError> {
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
                promise(.success(()))
            } catch {
                promise(.failure(.failedUpdatingContext))
            }
        }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "WorkoutTimer")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

}
