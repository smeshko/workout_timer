import XCTest
import ComposableArchitecture
import WorkoutCore
@testable import WorkoutDetails

class ActiveWorkoutTests: XCTestCase {
    
    let scheduler = DispatchQueue.testScheduler
    
    let workout = Workout(id: "", name: "Mock workout", imageKey: "", sets: [
        ExerciseSet(id: "jj-1", exercise: Exercise(id: "jump-1", name: "Jumping Jacks", imageKey: ""), duration: 2),
        ExerciseSet(id: "r-1", exercise: Exercise(id: "recovery", name: "Recovery", imageKey: ""), duration: 1),
        ExerciseSet(id: "jj-1", exercise: Exercise(id: "jump-1", name: "Jumping Jacks", imageKey: ""), duration: 1),
    ])
    
    func testFlow() {
        let store = TestStore(
            initialState: ActiveWorkoutState(workout: workout),
            reducer: activeWorkoutReducer,
            environment: ActiveWorkoutEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                soundClient: .mock
            )
        )
        
        store.assert(
            .send(.workoutBegin) {
                $0.isRunning = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 1
                $0.currentSetSecondsLeft = 1
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 2
                $0.currentSetSecondsLeft = 0
            },
            .receive(.moveToNextExercise) {
                $0.currentSet = self.workout.sets[1]
                $0.finishedWorkoutSets = 1
                $0.currentSetSecondsLeft = 1
                $0.nextSet = self.workout.sets.last!
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 3
                $0.currentSetSecondsLeft = 0
            },
            .receive(.moveToNextExercise) {
                $0.currentSet = self.workout.sets.last
                $0.finishedWorkoutSets = 2
                $0.currentSetSecondsLeft = 1
                $0.nextSet = nil
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 4
                $0.currentSetSecondsLeft = 0
            },
            .receive(.moveToNextExercise),
            .receive(.workoutFinished) {
                $0.isRunning = false
                $0.isFinished = true
            }
        )
    }
    
    func testStart_Pause() {
        let store = TestStore(
            initialState: ActiveWorkoutState(workout: workout),
            reducer: activeWorkoutReducer,
            environment: ActiveWorkoutEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                soundClient: .mock
            )
        )
        
        store.assert(
            .send(.workoutBegin) {
                $0.isRunning = true
            },
            .send(.pause) {
                $0.isRunning = false
            },
            .send(.resume) {
                $0.isRunning = true
            },
            .receive(.workoutBegin) {
                $0.isRunning = true
            },
            .send(.stopWorkout) {
                $0.isRunning = false
                $0.currentSetSecondsLeft = 0
            }
        )
    }
}


























































































