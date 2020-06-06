import Foundation
import WorkoutTimerAPI

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
    
    public init(dto: CategoryListDto) {
        self.id = dto.id
        self.name = dto.name
        self.workouts = dto.workouts?.map { Workout(dto: $0) } ?? []
    }
}
