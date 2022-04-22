import Foundation
import CoreData
import DomainEntities

extension QuickWorkoutDao {

    @nonobjc class func fetchRequest() -> NSFetchRequest<QuickWorkoutDao> {
        return NSFetchRequest<QuickWorkoutDao>(entityName: "QuickWorkoutDao")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var segments: NSSet?
    @NSManaged public var colorHue: Double
    @NSManaged public var colorSaturation: Double
    @NSManaged public var colorBrightness: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var countdown: Int16

    override func awakeFromInsert() {
        super.awakeFromInsert()
        createdAt = Date()
    }
}

// MARK: Generated accessors for segments
extension QuickWorkoutDao {

    @objc(addSegmentsObject:)
    @NSManaged public func addToSegments(_ value: QuickWorkoutSegmentDao)

    @objc(removeSegmentsObject:)
    @NSManaged public func removeFromSegments(_ value: QuickWorkoutSegmentDao)

    @objc(addSegments:)
    @NSManaged public func addToSegments(_ values: NSSet)

    @objc(removeSegments:)
    @NSManaged public func removeFromSegments(_ values: NSSet)

}

extension QuickWorkoutDao: Identifiable {}
extension QuickWorkoutDao: DatabaseEntity {
    func toDomainEntity() -> QuickWorkout {
        QuickWorkout(id: id ?? UUID(),
                     name: name ?? "",
                     color: WorkoutColor(hue: colorHue, saturation: colorSaturation, brightness: colorBrightness),
                     countdown: Int(countdown),
                     segments: segments?
                        .compactMap { $0 as? QuickWorkoutSegmentDao }
                        .sorted(by: { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) })
                        .map { $0.toDomainEntity() } ?? []
        )
    }

    func update(with new: QuickWorkout, in context: NSManagedObjectContext) {
        name = new.name
        colorHue = new.color.hue
        colorSaturation = new.color.saturation
        colorBrightness = new.color.brightness
        countdown = Int16(new.countdown)

        if let segments = segments {
            removeFromSegments(segments)
            addToSegments(NSSet(array: new.segments.map { $0.createDatabaseEntity(in: context) }))
        }
    }
}
