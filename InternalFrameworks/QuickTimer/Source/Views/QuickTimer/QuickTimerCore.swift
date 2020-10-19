import ComposableArchitecture
import Foundation
import WorkoutCore
import CorePersistence

public enum QuickTimerAction: Equatable {
    case setRunningTimer(isPresented: Bool)
    case circuitPickerUpdatedValues(AddTimerSegmentAction)
    case runningTimerAction(RunningTimerAction)
    case addTimerSegmentAction(id: UUID, action: AddTimerSegmentAction)
    case onAppear
    case didFetchSets(Result<[QuickTimerSet], PersistenceError>)
}

public struct QuickTimerState: Equatable {

    var isRunningTimerPresented = false
    var segments: [QuickTimerSet] = []

    var addTimerSegments: IdentifiedArrayOf<AddTimerSegmentState> = []
    var runningTimerState: RunningTimerState = RunningTimerState()
    
    public init() {}
}

public struct QuickTimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    var uuid: () -> UUID
    var repository: QuickTimerRepository
    var timerStep: DispatchQueue.SchedulerTimeType.Stride
    
    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient,
        repository: QuickTimerRepository,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(1)
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.soundClient = soundClient
        self.repository = repository
        self.timerStep = timerStep
    }
}

public let quickTimerReducer =
    Reducer<QuickTimerState, QuickTimerAction, QuickTimerEnvironment>.combine(
        addTimerSegmentReducer.forEach(
            state: \.addTimerSegments,
            action: /QuickTimerAction.addTimerSegmentAction(id:action:),
            environment: { AddTimerSegmentEnvironment(uuid: $0.uuid) }
        ),
        Reducer { state, action, environment in
            struct TimerId: Hashable {}
            
            switch action {
            case .onAppear:
                return environment.repository.fetchAllSets()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(QuickTimerAction.didFetchSets)

            case .setRunningTimer(isPresented: true):
                state.isRunningTimerPresented = true
                state.runningTimerState = RunningTimerState(segments: state.segments)

            case .setRunningTimer(isPresented: false):
                state.isRunningTimerPresented = false
                state.runningTimerState = RunningTimerState()

            case .runningTimerAction(let action):
                break

            case .addTimerSegmentAction(let id, .updatedSegments(let action, let segments)):
                switch action {
                case .add:
                    state.segments.append(contentsOf: segments)
                    state.addTimerSegments.append(defaultSegmentState(with: environment.uuid()))
                case .remove:
                    state.segments.removeAll { segments.map { $0.id }.contains($0.id) }
                    state.addTimerSegments.remove(id: id)
                }

            case .didFetchSets(.success(let sets)):
//                state.addTimerSegments =
                guard state.addTimerSegments.isEmpty else { return .none }
                state.addTimerSegments.append(defaultSegmentState(with: environment.uuid()))

            default: break
            }
            
            return .none
        },
        runningTimerReducer.pullback(
            state: \.runningTimerState,
            action: /QuickTimerAction.runningTimerAction,
            environment: { env in RunningTimerEnvironment(uuid: env.uuid, mainQueue: env.mainQueue, soundClient: env.soundClient)}
        )
)

private func defaultSegmentState(with id: UUID) -> AddTimerSegmentState {
    AddTimerSegmentState(id: id, sets: 2, workoutTime: 60, breakTime: 20)
}
