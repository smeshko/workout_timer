import CorePersistence
import ComposableArchitecture

public enum QuickWorkoutsListAction: Equatable {
    case onAppear
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case didFinishSaving(Result<QuickWorkout, PersistenceError>)
    case addWorkout
    case workoutCardAction(id: UUID, action: QuickWorkoutCardAction)
    case setCreateWorkout(isPresented: Bool)
    case createWorkoutAction(CreateQuickWorkoutAction)

}

public struct QuickWorkoutsListState: Equatable {
    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var isCreateWorkoutPresented = false
    var createWorkoutState = CreateQuickWorkoutState()

    public init() {}
}

public struct QuickWorkoutsListEnvironment {
    let repository: QuickTimerRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(repository: QuickTimerRepository, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.repository = repository
        self.mainQueue = mainQueue
    }
}

public let quickWorkoutsListReducer =
    Reducer<QuickWorkoutsListState, QuickWorkoutsListAction, QuickWorkoutsListEnvironment>.combine(
        quickWorkoutCardReducer.forEach(
            state: \.workoutStates,
            action: /QuickWorkoutsListAction.workoutCardAction(id:action:),
            environment: { _ in QuickWorkoutCardEnvironment() }
        ),
        Reducer { state, action, environment in

            switch action {
            case .onAppear:
                return environment.repository.fetchAllWorkouts()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(QuickWorkoutsListAction.didFetchWorkouts)

            case .setCreateWorkout(let isPresented):
                state.isCreateWorkoutPresented = isPresented
            case .didFetchWorkouts(.success(let workouts)):
                state.workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0) })

            case .addWorkout:
                state.createWorkoutState = CreateQuickWorkoutState()
                break
//                let new = QuickWorkout(id: UUID(), name: "Quick Workout", segments: [
//                    QuickWorkoutSegment(id: UUID(), sets: 5, work: 40, pause: 15),
//                    QuickWorkoutSegment(id: UUID(), sets: 5, work: 40, pause: 15)
//                ])
//                return environment.repository.createWorkout(new)
//                    .receive(on: environment.mainQueue)
//                    .catchToEffect()
//                    .map(QuickWorkoutsListAction.didFinishSaving)

            case .didFinishSaving(.success(let new)):
                state.workoutStates.append(QuickWorkoutCardState(workout: new))

            case .didFetchWorkouts(.failure(_)):
                break
                
            case .didFinishSaving(.failure(_)):
                break

            case .workoutCardAction(let id, let action):
                break

            case .createWorkoutAction(let action):
                break
            }

            return .none
        },
        createQuickWorkoutReducer.pullback(
            state: \.createWorkoutState,
            action: /QuickWorkoutsListAction.createWorkoutAction,
            environment: { env in CreateQuickWorkoutEnvironment(uuid: UUID.init, mainQueue: env.mainQueue, repository: env.repository)}
        )
    )

extension QuickWorkoutSegment {
    var stringRepresentation: String {
        "\(sets) sets of \(work) sec work and \(pause) pause in between."
    }
}
