import SwiftUI
import ComposableArchitecture
import WorkoutCore

struct QuickTimerControlsView: View {
    let store: Store<QuickTimerControlsState, QuickTimerControlsAction>
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        WithViewStore(store) { viewStore in
            if self.horizontalSizeClass == .regular {
                VStack(spacing: 32, content: { self.buttonContent(viewStore) })
            } else {
                HStack(spacing: 32, content: { self.buttonContent(viewStore) })
            }
        }
    }
    
    private func buttonContent(_ viewStore: ViewStore<QuickTimerControlsState, QuickTimerControlsAction>) -> some View {
        Group {
            if viewStore.timerState.isFinished {
                Button("Start", action: { viewStore.send(.start) })
                    .oval()
                
            } else if viewStore.timerState == .paused {
                Button("Continue", action: { viewStore.send(.start) })
                    .oval()
                
                Button("Finish", action: { viewStore.send(.stop) })
                    .oval()

            } else {
                Button("Pause", action: { viewStore.send(.pause) })
                    .oval()
            }
        }
        .font(.system(size: 22))
    }
}

struct TimerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTimerControlsView(
            store: Store<QuickTimerControlsState, QuickTimerControlsAction>(
                initialState: QuickTimerControlsState(timerState: .paused),
                reducer: quickTimerControlsReducer,
                environment: QuickTimerControlsEnvironment()
            )
        )
    }
}

struct Oval: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.vertical], 8)
            .padding([.horizontal], 16)
            .foregroundColor(Color.white)
            .background(Color.brand3)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.4), radius: 5)
    }
}

extension Button {
    func oval() -> some View {
        self.modifier(Oval())
    }
}
