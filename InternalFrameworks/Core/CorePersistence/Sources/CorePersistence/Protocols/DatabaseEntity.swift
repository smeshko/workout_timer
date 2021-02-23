import CoreData

protocol DatabaseEntity: NSManagedObject {

    associatedtype Entity: DomainEntity
    func toDomainEntity() -> Entity
    func update(with new: Entity, in context: NSManagedObjectContext)
}


