import XCTest
import ComposableArchitecture
import WorkoutCore
@testable import ActiveWorkout

class ActiveWorkoutTests: XCTestCase {
    
    let scheduler = DispatchQueue.testScheduler
    
    let workout = Workout(id: "", name: "Mock workout", image: "", sets: [
        ExerciseSet(exercise: Exercise(id: "jump-1", name: "Jumping Jacks", image: ""), duration: 2),
        ExerciseSet(exercise: Exercise(id: "recovery", name: "Recovery", image: ""), duration: 1)
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
                $0.currentSet = self.workout.sets.first!
                $0.sets = IdentifiedArrayOf<ActiveExerciseRowState>(self.workout.sets.enumerated().map { index, set in
                    var state = ActiveExerciseRowState(set: set)
                    state.isActive = index == 0
                    return state
                })
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 1
                $0.sets.applyChanges(to: $0.currentSet, { $0.secondsLeft = 1 })
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 2
                $0.sets.applyChanges(to: $0.currentSet, { $0.secondsLeft = 0 })
            },
            .receive(.moveToNextExercise) {
                $0.currentSet = self.workout.sets.last!
                $0.sets.applyChanges(to: $0.sets[0].set, { $0.isActive = false })
                $0.sets.applyChanges(to: $0.sets[1].set, { $0.isActive = true })
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeExpired = 3
                $0.sets.applyChanges(to: $0.currentSet, { $0.secondsLeft = 0 })
            },
            .receive(.moveToNextExercise) {
                $0.sets.applyChanges(to: $0.sets[1].set, { $0.isActive = false })
            },
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
                $0.currentSet = self.workout.sets.first!
                $0.sets = IdentifiedArrayOf<ActiveExerciseRowState>(self.workout.sets.enumerated().map { index, set in
                    var state = ActiveExerciseRowState(set: set)
                    state.isActive = index == 0
                    return state
                })
            },
            .send(.pause) {
                $0.isRunning = false
            },
            .send(.resume),
            .receive(.workoutBegin) {
                $0.isRunning = true
            },
            .send(.stopWorkout) {
                $0.isRunning = false
                $0.sets.applyChanges(to: $0.currentSet, { $0.isActive = false })
            }
        )
    }
}


























































































