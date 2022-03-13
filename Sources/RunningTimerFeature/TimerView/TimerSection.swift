import DomainEntities
import Foundation
import IdentifiedCollections

public struct TimerSection: Equatable, Identifiable {
    enum SectionType {
        case work, pause
    }

    public let id: UUID
    let duration: TimeInterval
    var timeLeft: TimeInterval
    let type: SectionType
    let name: String
    var isFinished: Bool = false

    init(id: UUID, duration: TimeInterval, type: TimerSection.SectionType, name: String, isFinished: Bool = false) {
        self.id = id
        self.duration = duration
        self.timeLeft = duration
        self.type = type
        self.name = name
        self.isFinished = isFinished
    }

    static func create(from segment: QuickWorkoutSegment) -> [TimerSection] {
        var sections: [TimerSection] = []

        (0 ..< segment.sets).forEach { index in
            sections.append(
                TimerSection(
                    id: UUID(),
                    duration: TimeInterval(segment.work),
                    type: .work,
                    name: segment.name
                )
            )
            guard segment.pause > 0 else { return }
            sections.append(
                TimerSection(
                    id: UUID(),
                    duration: TimeInterval(segment.pause),
                    type: .pause,
                    name: "Rest"
                )
            )
        }

        return sections
    }
}

extension Array where Element == TimerSection {
    var totalDuration: TimeInterval {
        TimeInterval(map(\.duration).reduce(0, +))
    }
}

extension IdentifiedArray where Element == TimerSection {
    var totalDuration: TimeInterval {
        TimeInterval(map(\.duration).reduce(0, +))
    }

    mutating func update<V>(_ identifier: ID?, keyPath: WritableKeyPath<TimerSection, V>, value: V) {
        guard let identifier = identifier, var element = self[id: identifier] else { return }
        element[keyPath: keyPath] = value
        updateOrAppend(element)
    }
}
