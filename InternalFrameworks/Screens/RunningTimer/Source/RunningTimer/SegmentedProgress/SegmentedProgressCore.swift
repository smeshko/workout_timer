import Foundation
import DomainEntities
import ComposableArchitecture

public struct ProgressSegment: Equatable {
    let id: UUID
    let finishedSets: Int
    let totalSets: Int

    var progress: Float {
        Float(finishedSets) / Float(totalSets)
    }

    var setsProgress: String {
        "\(finishedSets + 1)/\(totalSets)"
    }

    init(segment: QuickWorkoutSegment) {
        self.id = segment.id
        self.finishedSets = 0
        self.totalSets = segment.sets
    }

    init(id: UUID, finishedSets: Int, totalSets: Int) {
        self.id = id
        self.finishedSets = finishedSets
        self.totalSets = totalSets
    }

    func incrementingSets() -> ProgressSegment {
        ProgressSegment(id: id, finishedSets: finishedSets + 1, totalSets: totalSets)
    }
}

public enum SegmentedProgressAction: Equatable {
    case onChangeSizeClass(isCompact: Bool)
    case onTimerSectionFinished(TimerSection)
    case onSegmentFinished(ProgressSegment)
}

public struct SegmentedProgressState: Equatable {

    var isCompact: Bool
    var segments: [ProgressSegment]
    var currentIndex: Int = 0
    var currentSegment: ProgressSegment? {
        segments[safe: currentIndex]
    }

    public init(isCompact: Bool = true, segments: [QuickWorkoutSegment] = []) {
        self.isCompact = isCompact
        self.segments = segments.map(ProgressSegment.init(segment:))
    }
}

public struct SegmentedProgressEnvironment: Equatable {

    public init() {}
}

public let segmentedProgressReducer = Reducer<SegmentedProgressState, SegmentedProgressAction, SegmentedProgressEnvironment> { state, action, environment in

    switch action {
    case .onTimerSectionFinished(let section):
        guard let currentSegment = state.currentSegment,
              section.type == .work else { return .none }
        state.segments = state.segments.incrementingSets(of: currentSegment.id)
        if state.currentSegment?.progress == 1 {
            return Effect(value: SegmentedProgressAction.onSegmentFinished(currentSegment))
        }

    case .onSegmentFinished(let segment):
        state.currentIndex += 1

    case .onChangeSizeClass(let isCompact):
        state.isCompact = isCompact
    }
    return .none
}

private extension Array where Element == ProgressSegment {
    func incrementingSets(of id: UUID) -> [ProgressSegment] {
        guard let index = firstIndex(where: { $0.id == id }),
              let newSegment = self[safe: index]?.incrementingSets() else { return [] }

        var copy = self
        copy.remove(at: index)
        copy.insert(newSegment, at: index)
        return copy
    }
}
