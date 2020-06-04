import Foundation

public struct WorkoutCategory: Codable, Equatable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let workouts: [Workout]
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public init(id: String, name: String, workouts: [Workout] = []) {
        self.id = id
        self.name = name
        self.workouts = workouts
    }
}
