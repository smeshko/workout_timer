import CorePersistence
import ComposableArchitecture

public enum QuickWorkoutsListAction: Equatable {
    case onAppear
    case didFetchWorkouts(Result<[QuickWorkout], PersistenceError>)
    case didFinishDeletingWorkouts(Result<[String], PersistenceError>)
    case didFinishSaving(Result<QuickWorkout, PersistenceError>)
    case addWorkout
    case workoutCardAction(id: UUID, action: QuickWorkoutCardAction)
    case createWorkoutAction(CreateQuickWorkoutAction)
    case deleteWorkouts(IndexSet)
    case deleteWorkout(QuickWorkout)
}

public struct QuickWorkoutsListState: Equatable {
    var workoutStates: IdentifiedArrayOf<QuickWorkoutCardState> = []
    var createWorkoutState = CreateQuickWorkoutState()

    public init() {}
}

public struct QuickWorkoutsListEnvironment {
    let repository: QuickWorkoutsRepository
    let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(repository: QuickWorkoutsRepository, mainQueue: AnySchedulerOf<DispatchQueue>) {
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

            case .didFetchWorkouts(.success(let workouts)):
                state.workoutStates = IdentifiedArray(workouts.map { QuickWorkoutCardState(workout: $0, canStart: true) })

            case .addWorkout:
                state.createWorkoutState = CreateQuickWorkoutState()

            case .didFinishSaving(.success(let new)):
                state.workoutStates.append(QuickWorkoutCardState(workout: new, canStart: true))

            case .didFinishDeletingWorkouts(.success(let ids)):
                ids.forEach { state.workoutStates.remove(id: UUID(uuidString: $0) ?? UUID()) }

            case .didFinishDeletingWorkouts(.failure(let error)):
                break
                
            case .didFetchWorkouts(.failure(_)):
                break
                
            case .didFinishSaving(.failure(_)):
                break

            case .workoutCardAction(let id, let action):
                break

            case .createWorkoutAction(.cancel):
                state.createWorkoutState = CreateQuickWorkoutState()

            case .createWorkoutAction(.didSaveSuccessfully(.success(let workout))):
                state.workoutStates.insert(QuickWorkoutCardState(workout: workout, canStart: true), at: 0)
                state.createWorkoutState = CreateQuickWorkoutState()

            case .deleteWorkout(let workout):
                return environment
                    .repository
                    .delete(workout)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map {
                        QuickWorkoutsListAction.didFinishDeletingWorkouts($0.map { [$0] })
                    }

            case .deleteWorkouts(let indices):
                let objects = indices.compactMap { state.workoutStates[safe: $0]?.workout }
                return environment
                    .repository
                    .delete(objects)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(QuickWorkoutsListAction.didFinishDeletingWorkouts(_:))
                

            default: break
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
