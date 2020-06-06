import Foundation
import UIKit
import ComposableArchitecture
import WorkoutTimerAPI

public struct Workout: Codable, Equatable, Identifiable {
    
    public let id: String
    public let name: String
    public var image: String
    public let sets: [ExerciseSet]
    
    public init(id: String, name: String, image: String, sets: [ExerciseSet] = []) {
        self.id = id
        self.image = image
        self.name = name
        self.sets = sets
    }
    
    public init(dto: WorkoutGetDto) {
        self.id = dto.id
        self.name = dto.name
        self.image = dto.imageKey
        self.sets = dto.exerciseSets.map { ExerciseSet(dto: $0) }
    }
    
    public init(dto: WorkoutListDto) {
        self.id = dto.id
        self.name = dto.name
        self.image = dto.imageKey
        self.sets = dto.exerciseSets.map { ExerciseSet(dto: $0) }
    }
}
