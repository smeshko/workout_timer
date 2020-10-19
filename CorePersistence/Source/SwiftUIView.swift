import Combine
import SwiftUI

public struct SwiftUIView: View {

//    let client = CoreDataClient.shared

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<QuickTimerSetDao>

    public init() {}

    public var body: some View {
        VStack {

            List {
                ForEach(items) { item in
                    Text("Item with id: \(item.id?.uuidString ?? "")")
//                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: deleteItems)
            }
        }
        .toolbar {

            HStack {
                #if os(iOS)
                EditButton()
                #endif

                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .navigationTitle("App")
    }

    private func addItem() {
        withAnimation {
            let _ = QuickTimerSet(id: UUID.init, work: 30, pause: 10)
                .createDatabaseEntity(in: CoreDataClient.shared.container.viewContext)
            do {
                try CoreDataClient.shared.container.viewContext.save()
            } catch {

            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(CoreDataClient.shared.container.viewContext.delete)
            do {
                try CoreDataClient.shared.container.viewContext.save()
            } catch {

            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
