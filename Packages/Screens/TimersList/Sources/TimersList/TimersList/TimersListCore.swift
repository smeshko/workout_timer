import CorePersistence
import WorkoutSettings
import CoreLogic
import ComposableArchitecture
import DomainEntities
import CoreInterface
import NewTimerForm
import RunningTimer

public enum TimersListAction {
    case workoutCardAction(id: UUID, action: TimerCardAction)
//    case createWorkoutAction(CreateQuickWorkoutAction)
    case newTimerFormAction(NewTimerFormAction)
    case runningTimerAction(RunningTimerAction)
    case settingsAction(SettingsAction)

    case deleteWorkouts(IndexSet)
    case didFinishDeleting(Result<[String], PersistenceError>)
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case onUpdateQuery(String)

    case onSettingsPresentationChange(Bool)
    case onTimerFormPresentationChange(Bool)

    case onAppear
}

public struct TimersListState: Equatable {

    public var workouts: [QuickWorkout] = []

    var workoutStates: IdentifiedArrayOf<TimerCardState> = []
//    var createWorkoutState = CreateQuickWorkoutState()
    var newTimerFormState: NewTimerFormState?
    var settingsState = SettingsState()
    var runningTimerState: RunningTimerState?
    var loadingState: LoadingState = .finished
    var query: String = ""

    var isPresentingTimerForm = false
    var isPresentingSettings = false
    var isPresentingTimer = false
    var isPresentingTimerPreview = false

    public init(workouts: [QuickWorkout] = []) {
        self.workouts = workouts
        workoutStates = IdentifiedArray(uniqueElements: workouts.map { TimerCardState(workout: $0) })
    }
}

public struct TimersListEnvironment {
    let repository: QuickWorkoutsRepository
    let notificationClient: LocalNotificationClient

    public init(repository: QuickWorkoutsRepository,
                notificationClient: LocalNotificationClient) {
        self.repository = repository
        self.notificationClient = notificationClient
    }
}

public extension SystemEnvironment where Environment == TimersListEnvironment {
    static let preview = SystemEnvironment.mock(environment: TimersListEnvironment(repository: .mock, notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: TimersListEnvironment(repository: .live, notificationClient: .live))
}

public let timersListReducer = Reducer<TimersListState, TimersListAction, SystemEnvironment<TimersListEnvironment>>.combine(
    timerCardReducer.forEach(
        state: \.workoutStates,
        action: /TimersListAction.workoutCardAction(id:action:),
        environment: { _ in () }
    ),
    runningTimerReducer.optional().pullback(
        state: \.runningTimerState,
        action: /TimersListAction.runningTimerAction,
        environment: { _ in .live }
    ),
    newTimerFormReducer.optional().pullback(
        state: \.newTimerFormState,
        action: /TimersListAction.newTimerFormAction,
        environment: { env in .live(environment: NewTimerFormEnvironment(repository: env.repository)) }
    ),
    Reducer { state, action, environment in

        switch action {
        case .onAppear:
            state.loadingState = .loading
            return environment.fetchWorkouts()

        case .onSettingsPresentationChange(let isPresented):
            state.isPresentingSettings = isPresented

        case .onTimerFormPresentationChange(let isPresented):
            if isPresented {
                state.newTimerFormState = NewTimerFormState()
            }
            state.isPresentingTimerForm = isPresented

        case .onUpdateQuery(let query):
            state.query = query
            if query.isEmpty {
                state.workoutStates = IdentifiedArray(uniqueElements: state.workouts.map { TimerCardState(workout: $0) })
            } else {
                state.workoutStates = IdentifiedArray(
                    uniqueElements:
                        state.workouts
                        .filter { $0.name.lowercased().contains(query.lowercased()) }
                        .map { TimerCardState(workout: $0) }
                )
            }
            
        case .didFinishDeleting(.success(let ids)):
            ids.forEach { state.workoutStates.remove(id: UUID(uuidString: $0) ?? UUID()) }

        case .didFetchWorkouts(.success(let workouts)):
            state.loadingState = .finished
            state.workouts = workouts
            state.workoutStates = IdentifiedArray(uniqueElements: workouts.map { TimerCardState(workout: $0) })

        case .didFinishDeleting(.failure), .didFetchWorkouts(.failure):
            state.loadingState = .error

        case .workoutCardAction(let id, action: .start):
            guard let workout = state.workoutStates[id: id]?.workout else { break }
            state.runningTimerState = RunningTimerState(workout: workout, precountdownState: PreCountdownState(workoutColor: workout.color))
            state.isPresentingTimer = true

        case .workoutCardAction(let id, action: .edit):
            state.newTimerFormState = NewTimerFormState(workout: state.workoutStates[id: id]?.workout)
            state.isPresentingTimerForm = true

        case .workoutCardAction(let id, action: .delete):
            guard let workout = state.workoutStates[id: id]?.workout else { break }
            return environment
                .repository
                .delete(workout)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map {
                    TimersListAction.didFinishDeleting($0.map { [$0] })
                }
            
        case .runningTimerAction(.headerAction(.timerClosed)):
            state.isPresentingTimer = false
            state.runningTimerState = nil

        case .newTimerFormAction(.save), .newTimerFormAction(.cancel):
            return Effect(value: TimersListAction.onTimerFormPresentationChange(false))

        case .newTimerFormAction(.didSaveSuccessfully(.success(let workout))):
            state.loadingState = .loading
            state.newTimerFormState = nil
            return environment.fetchWorkouts()

        case .newTimerFormAction:
            break

        case .deleteWorkouts(let indices):
            let objects = indices.compactMap { state.workoutStates[safe: $0]?.workout }
            return environment
                .repository
                .deleteMultiple(objects)
                .receive(on: environment.mainQueue())
                .catchToEffect()
                .map(TimersListAction.didFinishDeleting(_:))

        case .settingsAction(.close):
            state.isPresentingSettings = false

        case .runningTimerAction, .settingsAction:
            break
        }
        return .none
    },
    settingsReducer.pullback(
        state: \.settingsState,
        action: /TimersListAction.settingsAction,
        environment: { _ in SettingsEnvironment(client: .live)}
    )
)

private extension SystemEnvironment where Environment == TimersListEnvironment {
    func fetchWorkouts() -> Effect<TimersListAction, Never> {
        environment.repository
            .fetchAllWorkouts()
            .receive(on: mainQueue())
            .catchToEffect()
            .map(TimersListAction.didFetchWorkouts)
    }
}
