import UIKit
import SwiftUI
import ComposableArchitecture
import CoreLogic

public struct List<EachState, EachAction, RowContent, RowPreview, Destination, Data, ID>: UIViewControllerRepresentable, KeyPathUpdateable
where Data: Collection, RowContent: View, RowPreview: View, Destination: View, EachState: Identifiable, EachState.ID == ID {

    private let data: IdentifiedArray<ID, EachState>
    private let store: Store<IdentifiedArray<ID, EachState>, (ID, EachAction)>
    private let content: (Store<EachState, EachAction>) -> RowContent

    private var onDelete: (IndexSet) -> Void = { _ in }
    private var actionProvider: (IndexSet) -> UIMenu? = { _ in nil }
    private var previewProvider: (Store<EachState, EachAction>) -> RowPreview? = { _ in nil }
    private var destination: (Store<EachState, EachAction>) -> Destination? = { _ in nil }

    public init(_ store: Store<Data, (ID, EachAction)>,
         content: @escaping (Store<EachState, EachAction>) -> RowContent)
    where
    Data == IdentifiedArray<ID, EachState>
    {
        self.store = store
        self.data = ViewStore(store, removeDuplicates: { _, _ in false }).state
        self.content = content
    }

    public init(_ store: Store<Data, (ID, EachAction)>,
         content: @escaping (Store<EachState, EachAction>) -> RowContent)
    where
    Data == IdentifiedArray<ID, EachState>,
    RowPreview == Never
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
        tableViewController.tableView.register(HostingCell<RowContent>.self, forCellReuseIdentifier: "Cell")
        return tableViewController
    }

    public func updateUIViewController(_ controller: UITableViewController, context: Context) {
        context.coordinator.rows = data.enumerated().map { offset, item in
            store.scope(state: { $0[safe: offset] ?? item },
                        action: { (item.id, $0) })
        }
        context.coordinator.navigationController = controller.navigationController
        if let _ = context.transaction.animation {
            UIView.transition(with: controller.tableView, duration: 0.15, options: .transitionCrossDissolve, animations: { controller.tableView.reloadData() })
        } else {
            controller.tableView.reloadData()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(rows: [],
                    content: content,
                    onDelete: onDelete,
                    actionProvider: actionProvider,
                    previewProvider: previewProvider,
                    destination: destination)
    }

    public func onDelete(_ action: @escaping (IndexSet) -> Void) -> List {
        update(\.onDelete, value: action)
    }

    public func previewProvider(_ provider: @escaping (Store<EachState, EachAction>) -> RowPreview?) -> Self {
        update(\.previewProvider, value: provider)
    }

    public func destination(_ provider: @escaping (Store<EachState, EachAction>) -> Destination?) -> Self {
        update(\.destination, value: provider)
    }

    public func actionProvider(_ provider: @escaping (IndexSet) -> UIMenu?) -> Self {
        update(\.actionProvider, value: provider)
    }

    public class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {

        fileprivate var rows: [Store<EachState, EachAction>]
        private var content: (Store<EachState, EachAction>) -> RowContent
        private var onDelete: (IndexSet) -> Void
        private var actionProvider: (IndexSet) -> UIMenu?
        private var previewProvider: (Store<EachState, EachAction>) -> RowPreview?
        private var destination: (Store<EachState, EachAction>) -> Destination?
        fileprivate var navigationController: UINavigationController?

        fileprivate init(rows: [Store<EachState, EachAction>],
                         content: @escaping (Store<EachState, EachAction>) -> RowContent,
                         onDelete: @escaping (IndexSet) -> Void,
                         actionProvider: @escaping (IndexSet) -> UIMenu?,
                         previewProvider: @escaping (Store<EachState, EachAction>) -> RowPreview?,
                         destination: @escaping (Store<EachState, EachAction>) -> Destination?) {
            self.rows = rows
            self.content = content
            self.onDelete = onDelete
            self.actionProvider = actionProvider
            self.previewProvider = previewProvider
            self.destination = destination
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

        public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            pushView(at: indexPath)
        }

        public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                onDelete(IndexSet(integer: indexPath.item))
            }
        }

        public func tableView(_ tableView: UITableView,
                              willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                              animator: UIContextMenuInteractionCommitAnimating) {

            if let identifier = configuration.identifier as? NSString,
               let indexPath = identifier.indexPath {
                self.pushView(at: indexPath)
            }
        }

        public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            guard let store = rows[safe: indexPath.row] else { return nil }

            return UIContextMenuConfiguration(
                identifier: indexPath.identification,
                previewProvider: {
                    guard let preview = self.previewProvider(store) else { return nil }
                    let hosting = UIHostingController<RowPreview>(rootView: preview)
                    return hosting
                },
                actionProvider: { _ in
                    self.actionProvider(IndexSet(integer: indexPath.item))
            })
        }

        private func pushView(at indexPath: IndexPath) {
            guard let store = rows[safe: indexPath.row],
                  let destination = destination(store) else { return }

            let host = UIHostingController<Destination>(rootView: destination)
            navigationController?.pushViewController(host, animated: true)
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

private extension IndexPath {
    var identification: NSString {
        NSString(string: "\(item)-\(section)")
    }
}

private extension NSString {
    var indexPath: IndexPath? {
        let string = String(self)
        let items = string.split(separator: "-")

        guard let item = Int(items[safe: 0] ?? ""), let section = Int(items[safe: 1] ?? "") else { return nil }

        return IndexPath(item: item, section: section)
    }
}
