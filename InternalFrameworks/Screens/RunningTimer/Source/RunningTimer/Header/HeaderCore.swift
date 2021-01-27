import Foundation
import ComposableArchitecture

public enum HeaderAction: Equatable {
    case closeButtonTapped
    case alertCancelTapped
    case alertConfirmTapped
    case alertDismissed

    case timerClosed
}

public struct HeaderState: Equatable {

    var timeLeft: TimeInterval
    var isFinished: Bool = false
    var alert: AlertState<HeaderAction>?
    var workoutName: String

    public init(timeLeft: TimeInterval = 0, workoutName: String = "") {
        self.timeLeft = timeLeft
        self.workoutName = workoutName
    }
}

public struct HeaderEnvironment {

    public init() {}
}

public let headerReducer = Reducer<HeaderState, HeaderAction, HeaderEnvironment> { state, action, environment in

    switch action {
    case .closeButtonTapped:
        if state.isFinished {
            return Effect(value: HeaderAction.timerClosed)
        } else {
            state.alert = .init(
                title: TextState("Stop workout?"),
                message: TextState("Are you sure you want to stop this workout?"),
                primaryButton: .cancel(send: .alertCancelTapped),
                secondaryButton: .default(TextState("Yes"), send: .alertConfirmTapped)
            )
        }

    default:
        break

    }

    return .none
}
