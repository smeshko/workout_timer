import CorePersistence
import CoreLogic
import ComposableArchitecture
import DomainEntities
import CoreInterface
import QuickWorkoutForm

public enum QuickWorkoutsListAction: Equatable {
    case workoutCardAction(id: UUID, action: QuickWorkoutCardAction)
    case createWorkoutAction(CreateQuickWorkoutAction)

    case deleteWorkouts(IndexSet)
    case deleteWorkout(QuickWorkout)
    case didFinishDeleting(Result<[String], PersistenceError>)
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)

    case onAppear
}

public struct QuickWorkoutsListState: Equatable {

    public var workouts: [QuickWorkout] = []

    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var createWorkoutState = CreateQuickWorkoutState()
    var loadingState: LoadingState = .finished

    public init(workouts: [QuickWorkout] = []) {
        self.workouts = workouts
        workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0, canStart: true) })
    }
}

public struct QuickWorkoutsListEnvironment<T> {
    let repository: QuickWorkoutsRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let uuid: () -> UUID
    let randomElementGenerator: ([T]) -> T?

    public init(repository: QuickWorkoutsRepository,
                mainQueue: AnySchedulerOf<DispatchQueue>,
                uuid: @escaping () -> UUID = UUID.init,
                randomElementGenerator: @escaping (_ elements: [T]) -> T? = { $0.randomElement() }) {
        self.repository = repository
        self.mainQueue = mainQueue
        self.uuid = uuid
        self.randomElementGenerator = randomElementGenerator
    }
}

public let quickWorkoutsListReducer = Reducer<QuickWorkoutsListState, QuickWorkoutsListAction, QuickWorkoutsListEnvironment<TintColor>>.combine(
    quickWorkoutCardReducer.forEach(
        state: \.workoutStates,
        action: /QuickWorkoutsListAction.workoutCardAction(id:action:),
        environment: { _ in QuickWorkoutCardEnvironment() }
    ),
    Reducer { state, action, environment in

        switch action {
        case .onAppear:
            state.loadingState = .loading
            return environment.fetchWorkouts()
            
        case .didFinishDeleting(.success(let ids)):
            ids.forEach { state.workoutStates.remove(id: UUID(uuidString: $0) ?? UUID()) }

        case .didFetchWorkouts(.success(let workouts)):
            state.loadingState = .finished
            state.workouts = workouts
            state.workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0, canStart: true) })

        case .didFinishDeleting(.failure), .didFetchWorkouts(.failure):
            state.loadingState = .error
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
        environment: { env in CreateQuickWorkoutEnvironment(mainQueue: env.mainQueue, repository: env.repository, uuid: env.uuid, randomElementGenerator: env.randomElementGenerator)}
    )
)

private extension QuickWorkoutsListEnvironment {
    func fetchWorkouts() -> Effect<QuickWorkoutsListAction, Never> {
        repository.fetchAllWorkouts()
            .receive(on: mainQueue)
            .catchToEffect()
            .map(QuickWorkoutsListAction.didFetchWorkouts)
    }
}
