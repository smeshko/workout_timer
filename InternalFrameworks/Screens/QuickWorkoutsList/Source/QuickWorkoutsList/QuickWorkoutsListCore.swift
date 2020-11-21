import CorePersistence
import CoreLogic
import ComposableArchitecture
import DomainEntities
import CoreInterface
import QuickWorkoutForm
import RunningTimer

public enum QuickWorkoutsListAction: Equatable {
    case workoutCardAction(id: UUID, action: QuickWorkoutCardAction)
    case createWorkoutAction(CreateQuickWorkoutAction)
    case runningTimerAction(RunningTimerAction)

    case deleteWorkouts(IndexSet)
    case deleteWorkout(QuickWorkout)
    case didFinishDeleting(Result<[String], PersistenceError>)
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case editWorkout(QuickWorkout)

    case onAppear
}

public struct QuickWorkoutsListState: Equatable {

    public var workouts: [QuickWorkout] = []

    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var createWorkoutState = CreateQuickWorkoutState()
    var runningTimerState: RunningTimerState?
    var loadingState: LoadingState = .finished
    var isPresentingTimer = false

    public init(workouts: [QuickWorkout] = []) {
        self.workouts = workouts
        workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0) })
    }
}

public struct QuickWorkoutsListEnvironment<T> {
    let repository: QuickWorkoutsRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let uuid: () -> UUID
    var notificationClient: LocalNotificationClient
    let randomElementGenerator: ([T]) -> T?

    public init(repository: QuickWorkoutsRepository,
                mainQueue: AnySchedulerOf<DispatchQueue>,
                notificationClient: LocalNotificationClient,
                uuid: @escaping () -> UUID = UUID.init,
                randomElementGenerator: @escaping (_ elements: [T]) -> T? = { $0.randomElement() }) {
        self.repository = repository
        self.mainQueue = mainQueue
        self.notificationClient = notificationClient
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
    runningTimerReducer.optional().pullback(
        state: \.runningTimerState,
        action: /QuickWorkoutsListAction.runningTimerAction,
        environment: { RunningTimerEnvironment(mainQueue: $0.mainQueue, soundClient: .live, notificationClient: .live) }
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
            state.workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0) })

        case .didFinishDeleting(.failure), .didFetchWorkouts(.failure):
            state.loadingState = .error
            break

        case .workoutCardAction(let id, action: .tapStart):
            guard let workout = state.workoutStates[id: id]?.workout else { break }
            state.runningTimerState = RunningTimerState(workout: workout)
            state.isPresentingTimer = true

        case .runningTimerAction(.finishedWorkoutAction(.didTapDoneButton)):
            state.runningTimerState = nil
            state.isPresentingTimer = false

        case .runningTimerAction:
            break

        case .createWorkoutAction(.didSaveSuccessfully(.success(let workout))):
            state.createWorkoutState = CreateQuickWorkoutState()
            state.loadingState = .loading
            return environment.fetchWorkouts()

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

        case .editWorkout(let workout):
            state.createWorkoutState = CreateQuickWorkoutState(workout: workout)
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
