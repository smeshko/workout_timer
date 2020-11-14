import Foundation

public struct QuickWorkoutSegment: Equatable, Identifiable, Hashable {
    public let id: UUID
    public let sets: Int
    public let work: Int
    public let pause: Int

    public init(id: UUID, sets: Int, work: Int, pause: Int) {
        self.id = id
        self.sets = sets
        self.work = work
        self.pause = pause
    }
}

public extension QuickWorkoutSegment {
    var duration: Int {
        sets * (work + pause)
    }
}
