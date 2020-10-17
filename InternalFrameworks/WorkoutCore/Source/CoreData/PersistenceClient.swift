import CoreData
import WorkoutTimerAPI
import Combine

public struct PersistenceClient {
    public static let shared = PersistenceClient()

    public static var preview: PersistenceClient = {
        let result = PersistenceClient(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    public let container: NSPersistentCloudKitContainer

    func create<T: DtoCreatable>(dto: T.Data, type: T.Type) {
        type.create(from: dto, in: container.viewContext)
    }

//    func create<T: NSManagedObject>(type: T) -> T? {
//        guard let entityDescription =  NSEntityDescription.entity(forEntityName: String.init(describing: type.self),
//                                                                  in: container.viewContext) else { return nil }
//        let entity = NSManagedObject(entity: entityDescription,
//                                     insertInto: container.viewContext)
//        return entity as? T
//    }

    public init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "WorkoutTimer")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
//        container.viewContext
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

}

protocol Dto {}
protocol DtoCreatable where Self: NSManagedObject {
    associatedtype Data: Dto
    associatedtype Entity: NSManagedObject
    static func create(from dto: Data, in context: NSManagedObjectContext) -> Entity
}

extension Exercise: Dto {}

extension ExerciseDao: DtoCreatable {
    static func create(from dto: Exercise, in context: NSManagedObjectContext) -> ExerciseDao {
        let exercise = ExerciseDao(context: context)
        exercise.id = UUID(uuidString: dto.id)
        exercise.name = dto.name
        exercise.imageKey = dto.imageKey
        exercise.thumbnailKey = dto.thumbnailKey
        return exercise

    }
}
