import CorePersistence

extension Array where Element == QuickTimerSet {
    func firstIndex(of segment: QuickTimerSet.Segment) -> Int? {
        firstIndex {
            $0.work == segment || $0.pause == segment
        }
    }
        
    subscript(_ segment: QuickTimerSet.Segment) -> QuickTimerSet? {
        first {
            $0.work == segment || $0.pause == segment
        }
    }
}
