import SwiftUI
import DomainEntities

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
    
    static var mockQuickWorkout1: QuickWorkout {
        QuickWorkout(id: UUID(), name: "Mock Workout 1", color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33), segments: [
            mockSegment1, mockSegment2
        ])
    }
    
    static var mockQuickWorkout2: QuickWorkout {
        QuickWorkout(id: UUID(), name: "Mock Workout 2", color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33), segments: [
            mockSegment3, mockSegment4
        ])
    }
    
    static var mockQuickWorkout3: QuickWorkout {
        QuickWorkout(id: UUID(), name: "Mock Workout 1", color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33), segments: [
            mockSegment1, mockSegment2, mockSegment3, mockSegment4
        ])
    }
    
    static var mockSegment1: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), sets: 2, work: 40, pause: 20)
    }
    static var mockSegment2: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), sets: 4, work: 60, pause: 20)
    }
    static var mockSegment3: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), sets: 10, work: 30, pause: 10)
    }
    static var mockSegment4: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), sets: 8, work: 60, pause: 40)
    }
}
