import DomainEntities
import Foundation

public struct TimerSection: Equatable {
    enum SectionType {
        case work, pause
    }

    let id: UUID
    let duration: TimeInterval
    let type: SectionType

    static func create(from segment: QuickWorkoutSegment) -> [TimerSection] {
        var sections: [TimerSection] = []

        (0 ..< segment.sets).forEach { index in
            sections.append(TimerSection(id: UUID(), duration: TimeInterval(segment.work), type: .work))
            sections.append(TimerSection(id: UUID(), duration: TimeInterval(segment.pause), type: .pause))
        }

        return sections
    }
}
