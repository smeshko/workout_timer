import UIKit
import SwiftUI
import ComposableArchitecture
import CoreLogic

public struct List<EachState, EachAction, RowContent, Data, ID>: UIViewControllerRepresentable, KeyPathUpdateable
where Data: Collection, RowContent: View, EachState: Identifiable, EachState.ID == ID {

    private let data: IdentifiedArray<ID, EachState>
    private let store: Store<IdentifiedArray<ID, EachState>, (ID, EachAction)>
    private let content: (Store<EachState, EachAction>) -> RowContent

    private var onDelete: (IndexSet) -> Void = { _ in }

    public init(_ store: Store<Data, (ID, EachAction)>,
                content: @escaping (Store<EachState, EachAction>) -> RowContent)
    where
    Data == IdentifiedArray<ID, EachState>
    {
        self.store = store
        self.data = ViewStore(store, removeDuplicates: { _, _ in false }).state
        self.content = content
    }

    public func makeUIViewController(context: Context) -> UITableViewController {
        let tableViewController = UITableViewController()
        tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewController.tableView.dataSource = context.coordinator
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.separatorStyle = .none
        tableViewController.tableView.allowsMultipleSelection = true
        tableViewController.tableView.register(HostingCell<RowContent>.self, forCellReuseIdentifier: "Cell")
        return tableViewController
    }

    public func updateUIViewController(_ controller: UITableViewController, context: Context) {
        context.coordinator.rows = data.enumerated().map { offset, item in
            store.scope(state: { $0[safe: offset] ?? item },
                        action: { (item.id, $0) })
        }
        controller.view.layoutIfNeeded()

        if let _ = context.transaction.animation {
            UIView.transition(with: controller.tableView, duration: 0.15, options: .transitionCrossDissolve, animations: { controller.tableView.reloadData() })
        } else {
            controller.tableView.reloadData()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(rows: [], content: content, onDelete: onDelete)
    }

    public func onDelete(_ action: @escaping (IndexSet) -> Void) -> List {
        update(\.onDelete, value: action)
    }

    public class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {

        fileprivate var rows: [Store<EachState, EachAction>]
        private var content: (Store<EachState, EachAction>) -> RowContent
        private var onDelete: (IndexSet) -> Void

        fileprivate init(rows: [Store<EachState, EachAction>],
                         content: @escaping (Store<EachState, EachAction>) -> RowContent,
                         onDelete: @escaping (IndexSet) -> Void
        ) {
            self.rows = rows
            self.content = content
            self.onDelete = onDelete
        }

        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            rows.count
        }

        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? HostingCell<RowContent>,
                  let view = rows[safe: indexPath.row] else {
                return UITableViewCell()
            }

            tableViewCell.setup(with: content(view))

            return tableViewCell
        }

        public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                onDelete(IndexSet(integer: indexPath.item))
            }
        }
    }
}

private class HostingCell<Content: View>: UITableViewCell {
    var host: UIHostingController<Content>?

    func setup(with view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: view)
            host = controller

            guard let content = controller.view else { return }
            content.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(content)

            content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            content.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            content.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        } else {
            host?.rootView = view
        }
        setNeedsLayout()
    }
}
