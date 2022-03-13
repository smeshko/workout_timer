import Foundation
import CoreData

protocol DomainEntity {

    associatedtype EntityObject: DatabaseEntity

    var objectId: String { get }

    func createDatabaseEntity(in context: NSManagedObjectContext) -> EntityObject
}
