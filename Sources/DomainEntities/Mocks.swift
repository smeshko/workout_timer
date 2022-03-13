import Foundation

public struct Mocks {
    public static var mockQuickWorkout1: QuickWorkout {
        QuickWorkout(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, name: "Mock Workout 1", color: .empty, countdown: 3, segments: [
            mockSegment1, mockSegment2
        ])
    }
    
    public static var mockQuickWorkout2: QuickWorkout {
        QuickWorkout(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Mock Workout 2", color: .empty, countdown: 3, segments: [
            mockSegment3, mockSegment4
        ])
    }
    
    public static var mockQuickWorkout3: QuickWorkout {
        QuickWorkout(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Mock Workout 3", color: .empty, countdown: 3, segments: [
            mockSegment1, mockSegment2, mockSegment3, mockSegment4
        ])
    }
    
    public static var mockSegment1: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, name: "Segment 1", sets: 2, work: 40, pause: 20)
    }
    public static var mockSegment2: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, name: "Segment 2", sets: 4, work: 60, pause: 20)
    }
    public static var mockSegment3: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, name: "Segment 3", sets: 10, work: 30, pause: 10)
    }
    public static var mockSegment4: QuickWorkoutSegment {
        QuickWorkoutSegment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, name: "Segment 4", sets: 8, work: 60, pause: 40)
    }
}
