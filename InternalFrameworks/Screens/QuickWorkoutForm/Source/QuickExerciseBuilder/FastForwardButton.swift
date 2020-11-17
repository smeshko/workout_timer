import SwiftUI

struct FastForwardButton<Content: View>: View {

    var action: () -> Void
    var buttonContent: () -> Content

    @State private var timer: Timer?
    @State private var isLongPressing = false

    var body: some View {
        Button(action: {
            if(isLongPressing) {
                isLongPressing.toggle()
                timer?.invalidate()
            } else {
                action()
            }
        }, label: {
            buttonContent()
        })
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.2)
                .onEnded { _ in
                    isLongPressing = true
                    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        action()
                    })
                }
        )
    }
}
