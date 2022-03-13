#if !os(watchOS)
import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {

    let subject: String
    let body: String
    let onFinished: () -> Void

    static var canSendEmail: Bool { MFMailComposeViewController.canSendMail() }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients(["pbandswift@gmail.com"])
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinished: () -> Void

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onFinished()
        }
    }
}
#endif
