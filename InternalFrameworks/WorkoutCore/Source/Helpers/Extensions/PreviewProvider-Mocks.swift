import SwiftUI

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
}
