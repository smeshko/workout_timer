public class QuickTimerRepository {

    private let store: LocalStore

    public init() {
        store = LocalStore(client: CoreDataClient.shared)
    }

    public func createTimerSet(_ set: QuickTimerSet) {
        store.create(set)
    }
}
