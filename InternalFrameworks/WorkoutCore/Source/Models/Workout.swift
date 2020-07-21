import Foundation
import UIKit
import ComposableArchitecture
import WorkoutTimerAPI

public enum Level: Int, Codable, Equatable {
    case beginner, intermediate, expert
}

public struct Workout: Codable, Equatable, Identifiable {
    
    public let id: String
    public let name: String
    public let imageKey: String
    public let thumbnailKey: String
    public let level: Level
    public let sets: [ExerciseSet]
    
    public init(id: String, name: String, imageKey: String, sets: [ExerciseSet] = [], level: Level = .beginner) {
        self.id = id
        self.imageKey = imageKey
        self.thumbnailKey = imageKey
        self.name = name
        self.sets = sets
        self.level = level
    }
    
    public init(dto: WorkoutGetDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.level = Level(rawValue: dto.level) ?? .beginner
        self.sets = dto.exerciseSets.map { ExerciseSet(dto: $0) }
    }
    
    public init(dto: WorkoutListDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.level = Level(rawValue: dto.level) ?? .beginner
        self.sets = dto.exerciseSets.map { ExerciseSet(dto: $0) }
    }
}
