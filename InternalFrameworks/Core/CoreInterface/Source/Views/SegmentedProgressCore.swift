import Foundation
import ComposableArchitecture

public enum SegmentedProgressAction: Equatable {
    case moveToNextSegment
    case onAppear
}

public struct SegmentedProgressState: Equatable {
    var totalSegments: Int = 0
    var filledSegments: Int = 0

    var title: String?
    var isCompact: Bool
    
    var totalFilledSegments: Int = 0
    var originalTotalCount: Int

    var shouldShowLabels: Bool {
        isAboveThreshold
    }

    var isAboveThreshold: Bool {
        let threshold = isCompact ? 10 : 20
        return originalTotalCount > threshold
    }

    var leftSegments: Int {
        totalSegments - filledSegments
    }

    var segmentLabelModifier: Int {
        step
    }

    public init(totalSegments: Int, filledSegments: Int = 0, title: String? = nil, isCompact: Bool) {
        self.originalTotalCount = totalSegments
        self.totalFilledSegments = filledSegments
        self.title = title
        self.isCompact = isCompact
    }

    func label(forIndex index: Int, filled: Bool) -> String {
        if filled {
            return "\(index * step)"
        } else {
            if index == leftSegments {
                return "\(totalSegments)"
            } else {
                return "\((index + filledSegments) * step)"
            }
        }
    }
}

public struct SegmentedProgressEnvironment: Equatable {

    public init() {}
}

public let segmentedProgressReducer = Reducer<SegmentedProgressState, SegmentedProgressAction, SegmentedProgressEnvironment> { state, action, environment in

    switch action {
    case .onAppear:
        state.totalSegments = adjustTotalSegments(state.originalTotalCount, isAboveThreshold: state.isAboveThreshold, isCompact: state.isCompact)
        state.filledSegments = adjustFilledSegments(state.totalFilledSegments, isAboveThreshold: state.isAboveThreshold, isCompact: state.isCompact)

    case .moveToNextSegment:
        state.totalFilledSegments += 1
        if state.totalFilledSegments == state.originalTotalCount {
            state.filledSegments += 1
        } else {
            state.filledSegments = adjustFilledSegments(state.totalFilledSegments, isAboveThreshold: state.isAboveThreshold, isCompact: state.isCompact)
        }
    }
    return .none
}

private func adjustFilledSegments(_ initialCount: Int, isAboveThreshold: Bool, isCompact: Bool) -> Int {
    guard isAboveThreshold else { return initialCount }
    return Int(floor(Double(initialCount) / Double(step)))
}

private func adjustTotalSegments(_ initialCount: Int, isAboveThreshold: Bool, isCompact: Bool) -> Int {
    guard isAboveThreshold else { return initialCount }

    let newSegmentCount = Int(floor(Double(initialCount) / Double(step)))
    let additionalSegment = (initialCount % step) > 0 ? 1 : 0

    return newSegmentCount + additionalSegment
}

private let step = 5
