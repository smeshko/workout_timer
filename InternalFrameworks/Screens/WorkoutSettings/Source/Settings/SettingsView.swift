import SwiftUI
import CoreInterface
import MessageUI
import ComposableArchitecture
import StoreKit

public struct SettingsView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    private var canSendEmail: Bool { MFMailComposeViewController.canSendMail() }

    @State private var isPresentingLicenses = false

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customization")) {
                    VStack(alignment: .leading) {
                        Toggle("Enable sound", isOn: viewStore.binding(get: \.sound, send: SettingsAction.toggleSound))
                        Text("The app plays sounds while the timer is running or when an interval is finished.")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                    VStack(alignment: .leading) {
                        Toggle("Keep screen on", isOn: viewStore.binding(get: \.keepScreen, send: SettingsAction.toggleScreen))
                        Text("Choose to disable auto-locking the screen while using the app.")
                            .font(.bodySmall)
                            .padding(.bottom, Spacing.xxs)
                    }
                }

                Section(header: Text("Support")) {
                    if canSendEmail {
                        Button("Report a bug") {
                            viewStore.send(.sendBugReport)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button("Feature request") {
                            viewStore.send(.sendBugReport)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button("Rate the app") {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Section(header: Text("Legal")) {
                    Button("Privacy policy") {

                    }
                    .buttonStyle(PlainButtonStyle())

                    Button("Licenses") {
                        isPresentingLicenses = true
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text("Version \(viewStore.versionNumber)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isPresentingMailComposer,
                send: SettingsAction.didPresentMailComposer
            ), content: {
                MailView(subject: viewStore.mailSubject, body: viewStore.mailBody) { _ in
                    viewStore.send(.didFinishComposingMail)
                }
            })
            .sheet(isPresented: $isPresentingLicenses, content: {
                LicensesView()
            })
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            store: Store<SettingsState, SettingsAction>(
                initialState: SettingsState(),
                reducer: settingsReducer,
                environment: SettingsEnvironment(client: .mock)
            )
        )
    }
}

private struct MailView: UIViewControllerRepresentable {

    let subject: String
    let body: String
    let onFinished: (MFMailComposeResult) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients(["ivaylo.tsonev@outlook.com"])
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinished: (MFMailComposeResult) -> Void

        init(onFinished: @escaping (MFMailComposeResult) -> Void) {
            self.onFinished = onFinished
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onFinished(result)
        }
    }
}
