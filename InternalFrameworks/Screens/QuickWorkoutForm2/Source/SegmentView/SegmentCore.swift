import Foundation
import ComposableArchitecture

public enum SegmentAction: Equatable {

}

struct SegmentState: Equatable, Identifiable {
    let id: UUID
    let name: String
    let sets: Int
    let rest: Int
    let work: Int

    public init(id: UUID, name: String = "", sets: Int = 0, rest: Int = 0, work: Int = 0) {
        self.id = id
        self.name = name
        self.sets = sets
        self.rest = rest
        self.work = work
    }
}

struct SegmentEnvironment {

    public init() {}
}

let segmentReducer = Reducer<SegmentState, SegmentAction, SegmentEnvironment> { state, action, environment in


    return .none
}
