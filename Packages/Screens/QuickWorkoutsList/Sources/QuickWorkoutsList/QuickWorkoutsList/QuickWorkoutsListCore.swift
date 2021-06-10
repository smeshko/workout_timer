import CorePersistence
import WorkoutSettings
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
    case settingsAction(SettingsAction)

    case deleteWorkouts(IndexSet)
    case deleteWorkout(QuickWorkout)
    case didFinishDeleting(Result<[String], PersistenceError>)
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case editWorkout(QuickWorkout)
    case onUpdateQuery(String)
    case refresh

    case timerForm(PresenterAction)
    case settings(PresenterAction)

    case onAppear
}

public struct QuickWorkoutsListState: Equatable {

    public var workouts: [QuickWorkout] = []

    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var createWorkoutState = CreateQuickWorkoutState()
    var settingsState = SettingsState()
    var runningTimerState: RunningTimerState?
    var loadingState: LoadingState = .finished
    var isPresentingTimer = false
    var query: String = ""

    var isPresentingTimerForm = false
    var isPresentingSettings = false

    public init(workouts: [QuickWorkout] = []) {
        self.workouts = workouts
        workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0) })
    }
}

public struct QuickWorkoutsListEnvironment {
    let repository: QuickWorkoutsRepository
    let notificationClient: LocalNotificationClient

    public init(repository: QuickWorkoutsRepository,
                notificationClient: LocalNotificationClient) {
        self.repository = repository
        self.notificationClient = notificationClient
    }
}

public extension SystemEnvironment where Environment == QuickWorkoutsListEnvironment {
    static let preview = SystemEnvironment.mock(environment: QuickWorkoutsListEnvironment(repository: .mock, notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: QuickWorkoutsListEnvironment(repository: .live, notificationClient: .live))
}

public let quickWorkoutsListReducer = Reducer<QuickWorkoutsListState, QuickWorkoutsListAction, SystemEnvironment<QuickWorkoutsListEnvironment>>.combine(
    quickWorkoutCardReducer.forEach(
        state: \.workoutStates,
        action: /QuickWorkoutsListAction.workoutCardAction(id:action:),
        environment: { _ in QuickWorkoutCardEnvironment() }
    ),
    runningTimerReducer.optional().pullback(
        state: \.runningTimerState,
        action: /QuickWorkoutsListAction.runningTimerAction,
        environment: { _ in .live }
    ),
    Reducer { state, action, environment in

        switch action {
        case .onAppear:
            state.loadingState = .loading
            return environment.fetchWorkouts()

        case .refresh:
            state.loadingState = .loading
            return environment.fetchWorkouts()

        case .onUpdateQuery(let query):
            state.query = query
            if query.isEmpty {
                state.workoutStates = IdentifiedArray(state.workouts.map { QuickWorkoutCardState(workout: $0) })
            } else {
                state.workoutStates = IdentifiedArray(
                    state.workouts
                        .filter { $0.name.contains(query) }
                        .map { QuickWorkoutCardState(workout: $0) }
                )
            }
            
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
            state.runningTimerState = RunningTimerState(workout: workout, precountdownState: PreCountdownState(workoutColor: workout.color))
            state.isPresentingTimer = true

        case .runningTimerAction(.headerAction(.timerClosed)):
            state.isPresentingTimer = false
            state.runningTimerState = nil

        case .createWorkoutAction(.didSaveSuccessfully(.success(let workout))):
            state.loadingState = .loading
            return environment.fetchWorkouts()

        case .createWorkoutAction(.cancel), .createWorkoutAction(.save):
            return Effect(value: QuickWorkoutsListAction.timerForm(.dismiss))

        case .deleteWorkout(let workout):
            return environment
                .repository
                .delete(workout)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map {
                    QuickWorkoutsListAction.didFinishDeleting($0.map { [$0] })
                }

        case .deleteWorkouts(let indices):
            let objects = indices.compactMap { state.workoutStates[safe: $0]?.workout }
            return environment
                .repository
                .deleteMultiple(objects)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map(QuickWorkoutsListAction.didFinishDeleting(_:))

        case .editWorkout(let workout):
            state.createWorkoutState = CreateQuickWorkoutState(workout: workout)

        case .timerForm(.dismiss):
            state.createWorkoutState.workout = nil

        case .timerForm(.present):
            if state.createWorkoutState.workout == nil {
                state.createWorkoutState = CreateQuickWorkoutState()
            }

        case .settingsAction(.close):
            return Effect(value: QuickWorkoutsListAction.settings(.dismiss))

        case .createWorkoutAction, .runningTimerAction, .settings, .settingsAction:
            break
        }
        return .none
    }
    .presenter(
        keyPath: \.isPresentingTimerForm,
        action: /QuickWorkoutsListAction.timerForm
    )
    .presenter(
        keyPath: \.isPresentingSettings,
        action: /QuickWorkoutsListAction.settings
    ),
    settingsReducer.pullback(
        state: \.settingsState,
        action: /QuickWorkoutsListAction.settingsAction,
        environment: { _ in SettingsEnvironment(client: .live)}
    ),
    createQuickWorkoutReducer.pullback(
        state: \.createWorkoutState,
        action: /QuickWorkoutsListAction.createWorkoutAction,
        environment: { env in .live(environment: CreateQuickWorkoutEnvironment<TintColor>(repository: env.repository)) }
    )
)

private extension SystemEnvironment where Environment == QuickWorkoutsListEnvironment {
    func fetchWorkouts() -> Effect<QuickWorkoutsListAction, Never> {
        environment.repository
            .fetchAllWorkouts()
            .receive(on: mainQueue())
            .catchToEffect()
            .map(QuickWorkoutsListAction.didFetchWorkouts)
    }
}
