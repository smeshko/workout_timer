import CorePersistence
import ComposableArchitecture

public enum QuickWorkoutsListAction: Equatable {
    case workoutCardAction(id: UUID, action: QuickWorkoutCardAction)
    case createWorkoutAction(CreateQuickWorkoutAction)

    case deleteWorkouts(IndexSet)
    case deleteWorkout(QuickWorkout)
    case didFinishDeleting(Result<[String], PersistenceError>)
}

public struct QuickWorkoutsListState: Equatable {

    public var workouts: [QuickWorkout] = []

    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var createWorkoutState = CreateQuickWorkoutState()

    public init(workouts: [QuickWorkout] = []) {
        self.workouts = workouts
        workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0, canStart: true) })
    }
}

public struct QuickWorkoutsListEnvironment {
    let repository: QuickWorkoutsRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(repository: QuickWorkoutsRepository, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.repository = repository
        self.mainQueue = mainQueue
    }
}

public let quickWorkoutsListReducer = Reducer<QuickWorkoutsListState, QuickWorkoutsListAction, QuickWorkoutsListEnvironment>.combine(
    quickWorkoutCardReducer.forEach(
        state: \.workoutStates,
        action: /QuickWorkoutsListAction.workoutCardAction(id:action:),
        environment: { _ in QuickWorkoutCardEnvironment() }
    ),
    Reducer { state, action, environment in

        switch action {
        case .didFinishDeleting(.success(let ids)):
            ids.forEach { state.workoutStates.remove(id: UUID(uuidString: $0) ?? UUID()) }

        case .didFinishDeleting(.failure):
            break

        case .workoutCardAction(let id, let action):
            break

        case .createWorkoutAction(.didSaveSuccessfully(.success(let workout))):
            state.workoutStates.insert(QuickWorkoutCardState(workout: workout, canStart: true), at: 0)
            state.createWorkoutState = CreateQuickWorkoutState()

        case .createWorkoutAction(.cancel):
            state.createWorkoutState = CreateQuickWorkoutState()

        case .createWorkoutAction:
            break

        case .deleteWorkout(let workout):
            return environment
                .repository
                .delete(workout)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map {
                    QuickWorkoutsListAction.didFinishDeleting($0.map { [$0] })
                }

        case .deleteWorkouts(let indices):
            let objects = indices.compactMap { state.workoutStates[safe: $0]?.workout }
            return environment
                .repository
                .deleteMultiple(objects)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(QuickWorkoutsListAction.didFinishDeleting(_:))
        }

        return .none
    },
    createQuickWorkoutReducer.pullback(
        state: \.createWorkoutState,
        action: /QuickWorkoutsListAction.createWorkoutAction,
        environment: { env in CreateQuickWorkoutEnvironment(mainQueue: env.mainQueue, repository: env.repository)}
    )
)
