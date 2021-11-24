import Foundation
import UIKit
import CoreInterface
import ComposableArchitecture
import CoreLogic
import DomainEntities

public enum TimerViewAction: Equatable {
    case timerBegin
    case timerTick
    case timerFinish
    case sectionEnded

    case pause
    case resume
}

public struct TimerViewState: Equatable {
    let workout: QuickWorkout
    var totalTimeLeft: TimeInterval = 0
    var timerSections: IdentifiedArrayOf<TimerSection>
    var isRunning: Bool = false
    var currentSection: TimerSection? {
        timerSections.first { $0.isFinished == false }
    }
    var finishedSections: Int {
        timerSections.filter { $0.type == .work && $0.isFinished == true }.count
    }

    var totalTimeExpired: TimeInterval {
        timerSections.totalDuration - totalTimeLeft
    }

    public init(workout: QuickWorkout) {
        self.workout = workout
        self.timerSections = IdentifiedArray(uniqueElements: workout.segments.map(TimerSection.create(from:)).flatMap { $0 }.dropLast())
        self.totalTimeLeft = timerSections.totalDuration
    }
}

public struct TimerViewEnvironment {
    var soundClient: SoundClient
    var notificationClient: LocalNotificationClient
    var timerStep: DispatchQueue.SchedulerTimeType.Stride

    public init(
        soundClient: SoundClient,
        notificationClient: LocalNotificationClient,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.05)
    ) {
        self.soundClient = soundClient
        self.notificationClient = notificationClient
        self.timerStep = timerStep
    }
}

public extension SystemEnvironment where Environment == TimerViewEnvironment {
    static let preview = SystemEnvironment.mock(environment: TimerViewEnvironment(soundClient: .mock, notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: TimerViewEnvironment(soundClient: .live, notificationClient: .live))
}

public let timerViewReducer = Reducer<TimerViewState, TimerViewAction, SystemEnvironment<TimerViewEnvironment>>.combine(
    Reducer { state, action, environment in
        struct TimerId: Hashable {}
        let id = TimerId()

        switch action {

        case .resume:
            state.isRunning = true
            return Effect
                .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                .map { _ in TimerViewAction.timerTick }

        case .timerTick:
            state.totalTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            state.timerSections.update(state.currentSection?.id, keyPath: \.timeLeft, value: (state.currentSection?.timeLeft ?? 0) - (environment.timerStep.timeInterval.asDouble ?? 0))

            if state.totalTimeLeft <= 0 {
                state.timerSections.update(state.currentSection?.id, keyPath: \.isFinished, value: true)
                return Effect(value: TimerViewAction.timerFinish)
            }

            if (state.currentSection?.timeLeft ?? 0) <= 0 {
                return Effect(value: TimerViewAction.sectionEnded)
            }

        case .timerFinish:
            return Effect<TimerViewAction, Never>.cancel(id: id)

        case .timerBegin:
            state.isRunning = true
            return Effect
                .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                .map { _ in TimerViewAction.timerTick }

        case .sectionEnded:
            state.timerSections.update(state.currentSection?.id, keyPath: \.isFinished, value: true)
//            guard environment.settings.soundEnabled else { break }
//            return environment
//                .soundClient
//                .play(.segment)
//                .fireAndForget()

        default:
            state.isRunning = false
            return Effect<TimerViewAction, Never>.cancel(id: id)
        }

        return .none
    }
)
