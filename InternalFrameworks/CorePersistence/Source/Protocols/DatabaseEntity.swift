import CoreData

protocol DatabaseEntity: NSManagedObject {

    associatedtype Entity: DomainEntity
    func toDomainEntity() -> Entity
}
