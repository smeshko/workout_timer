import Foundation

public enum LoadingState {
    case loading
    case finished
    case error

    public var isLoading: Bool {
        self == .loading
    }

    public var isFinished: Bool {
        self == .finished
    }

    public var isError: Bool {
        self == .error
    }
}
