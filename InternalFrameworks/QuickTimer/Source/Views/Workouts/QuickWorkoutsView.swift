import SwiftUI
import CorePersistence
import ComposableArchitecture

public struct QuickWorkoutsView: View {

    let store = Store<QuickWorkoutsState, QuickWorkoutsAction>(
        initialState: QuickWorkoutsState(workouts: []),
        reducer: quickWorkoutsReducer,
        environment: QuickWorkoutsEnvironment(repository: QuickTimerRepository(), mainQueue: DispatchQueue.main.eraseToAnyScheduler())
    )

    public init() {}

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    ForEach(viewStore.workouts) { workout in
                        VStack {
                            Text(workout.name)
                            ForEach(workout.segments) { segment in
                                Text(segment.stringRepresentation)
                            }
                        }
                    }
                }
            }
            .toolbar {

                HStack {
                    #if os(iOS)
                    EditButton()
                    #endif

                    Button(action: { viewStore.send(.addWorkout) }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("App")
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}


public enum QuickWorkoutsAction: Equatable {
    case onAppear
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case didFinishSaving(Result<QuickWorkout, PersistenceError>)
    case addWorkout
}

public struct QuickWorkoutsState: Equatable {
    var workouts: [QuickWorkout]
}

public struct QuickWorkoutsEnvironment {
    let repository: QuickTimerRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

public let quickWorkoutsReducer = Reducer<QuickWorkoutsState, QuickWorkoutsAction, QuickWorkoutsEnvironment> { state, action, environment in

    switch action {
    case .onAppear:
        return environment.repository.fetchAllWorkouts()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(QuickWorkoutsAction.didFetchWorkouts)

    case .didFetchWorkouts(.success(let workouts)):
        state.workouts = workouts

    case .addWorkout:
        let new = QuickWorkout(id: UUID(), name: "Quick Workout", segments: [
            QuickWorkoutSegment(id: UUID(), sets: 5, work: 40, pause: 15),
            QuickWorkoutSegment(id: UUID(), sets: 5, work: 40, pause: 15)
        ])
        return environment.repository.createWorkout(new)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(QuickWorkoutsAction.didFinishSaving)

    case .didFinishSaving(.success(let new)):
        state.workouts.append(new)

    case .didFetchWorkouts(.failure(_)):
        break
    case .didFinishSaving(.failure(_)):
        break
    }

    return .none
}

extension QuickWorkoutSegment {
    var stringRepresentation: String {
        "\(sets) sets of \(work) sec work and \(pause) pause in between."
    }
}
