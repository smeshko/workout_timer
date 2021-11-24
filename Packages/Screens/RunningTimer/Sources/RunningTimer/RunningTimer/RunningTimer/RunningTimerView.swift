import SwiftUI
import ComposableArchitecture
import CoreInterface
import CorePersistence

public struct RunningTimerView: View {

    let store: Store<RunningTimerState, RunningTimerAction>
    @Environment(\.scenePhase) var scenePahse

    public init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.stateless) { viewStore in
            IfLetStore(store.scope(state: \.precountdownState, action: RunningTimerAction.preCountdownAction),
                       then: { CountdownView(store: $0) },
                       else: { MainView(store: store) }
            )
            .padding(Spacing.xxl)
            .onChange(of: scenePahse) { newScene in
                switch newScene {
                case .background:
                    viewStore.send(.onBackground)
                default: break
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct RunningTimerView_Previews: PreviewProvider {
    static var previews: some View {
        let runningStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                currentSection: TimerSection(id: UUID(), duration: 45, type: .work, name: "Jump rope"),
                precountdownState: nil,
                timerControlsState: TimerControlsState(timerState: .running)
            ),
            reducer: runningTimerReducer,
            environment: .preview
        )
        let preCountdownStore = Store<RunningTimerState, RunningTimerAction>(
            initialState: RunningTimerState(
                workout: mockQuickWorkout1,
                precountdownState: CountdownState(workoutColor: mockQuickWorkout1.color)
            ),
            reducer: runningTimerReducer,
            environment: .preview
        )

        return Group {
            RunningTimerView(store: preCountdownStore)
                .previewDevice(.iPhone11)

            RunningTimerView(store: runningStore)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)

            RunningTimerView(store: runningStore)
                .previewLayout(.landscape(.iPhone11))
        }
    }
}
