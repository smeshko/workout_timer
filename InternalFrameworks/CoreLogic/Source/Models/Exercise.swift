import Foundation
import WorkoutTimerAPI
import SwiftUI

public struct Exercise: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let imageKey: String
    public let thumbnailKey: String
    public let muscles: [String]
    public let steps: [String]
    public let level: Level

    public init(id: String, name: String, imageKey: String, muscles: [String] = [], steps: [String] = [], level: Level = .beginner) {
        self.id = id
        self.name = name
        self.imageKey = imageKey
        self.thumbnailKey = imageKey
        self.muscles = muscles
        self.steps = steps
        self.level = level
    }
    
    public init(dto: ExerciseGetDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.muscles = dto.muscles
        self.steps = dto.steps
        self.level = Level(rawValue: dto.level) ?? .beginner
    }

    public init(dto: ExerciseListDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.level = Level(rawValue: dto.level) ?? .beginner
        self.muscles = []
        self.steps = []
    }
}

public extension PreviewProvider {
    static var mockExercise1: Exercise {
        Exercise(id: "mock-exercise-1", name: "Mock Exercise 1", imageKey: "preview-exercise-1")
    }

    static var mockExercise2: Exercise {
        Exercise(id: "mock-exercise-2", name: "Mock Exercise 2", imageKey: "preview-exercise-2")
    }

    static var mockExercise3: Exercise {
        Exercise(id: "mock-exercise-3", name: "Mock Exercise 3", imageKey: "preview-exercise-3")
    }

    static var mockWorkout1: Workout {
        Workout(id: "mock-workout-1", name: "Mock Workout 1", imageKey: "preview-exercise-4", sets: [
            ExerciseSet(id: "mock-set-1", exercise: mockExercise1, duration: 60),
            ExerciseSet(id: "mock-set-2", exercise: mockExercise2, duration: 45),
            ExerciseSet(id: "mock-set-3", exercise: mockExercise3, duration: 60)
        ])
    }

    static var mockWorkout2: Workout {
        Workout(id: "mock-workout-2", name: "Mock Workout 2", imageKey: "preview-workout-1", sets: [
            ExerciseSet(id: "mock-set-1", exercise: mockExercise1, duration: 60),
            ExerciseSet(id: "mock-set-2", exercise: mockExercise2, duration: 45),
            ExerciseSet(id: "mock-set-3", exercise: mockExercise3, duration: 60)
        ])
    }

    static var mockCategory1: WorkoutCategory {
        WorkoutCategory(id: "category-1", name: "Mock Category 1", workouts: [
            mockWorkout1,
            mockWorkout2
        ])
    }
}
