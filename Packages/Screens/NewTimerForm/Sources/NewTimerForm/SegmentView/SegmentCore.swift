import Foundation
import SwiftUI
import ComposableArchitecture

public enum SegmentAction: BindableAction, Equatable {

    case binding(BindingAction<SegmentState>)
}

public struct SegmentState: Equatable, Identifiable {
    public let id: UUID
    @BindableState var name: String
    @BindableState var sets: Int
    @BindableState var rest: Int
    @BindableState var work: Int
    let color: Color

    public init(id: UUID, name: String = "", sets: Int = 0, rest: Int = 0, work: Int = 0, color: Color) {
        self.id = id
        self.name = name
        self.sets = sets
        self.rest = rest
        self.work = work
        self.color = color
    }
}

struct SegmentEnvironment {

    public init() {}
}

let segmentReducer = Reducer<SegmentState, SegmentAction, SegmentEnvironment> { state, action, environment in

    switch action {
    case .binding:
        break
    }

    return .none
}
    .binding()
