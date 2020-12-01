import SwiftUI
import DomainEntities

public extension PreviewProvider {
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
        QuickWorkout(id: UUID(), name: "Mock Workout 3", color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33), segments: [
            mockSegment1, mockSegment2, mockSegment3, mockSegment4
        ])
    }
    
    static var mockSegment1: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), name: "Segment 1", sets: 2, work: 40, pause: 20)
    }
    static var mockSegment2: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), name: "Segment 2", sets: 4, work: 60, pause: 20)
    }
    static var mockSegment3: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), name: "Segment 3", sets: 10, work: 30, pause: 10)
    }
    static var mockSegment4: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(), name: "Segment 4", sets: 8, work: 60, pause: 40)
    }
}
