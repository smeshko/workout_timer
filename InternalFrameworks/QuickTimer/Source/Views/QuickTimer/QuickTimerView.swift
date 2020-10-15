import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct QuickTimerView: View {

    let store: Store<QuickTimerState, QuickTimerAction>
    
    public init(store: Store<QuickTimerState, QuickTimerAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEachStore(self.store.scope(state: { $0.addTimerSegments }, action: QuickTimerAction.addTimerSegmentAction(id:action:))) { viewStore in
                            AddTimerSegmentView(store: viewStore)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 18)
                                .background(Color.appCardBackground)
                                .cornerRadius(12)
                                .padding(.bottom, 8)
                            
                        }
                    }
                    .padding(.horizontal, 28)

                    Spacer()

                    Button(action: {
                        viewStore.send(.setRunningTimer(isPresented: true))
                    }, label: {
                        Text("Start")
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(Color.appPrimary)
                            .foregroundColor(.appWhite)
                            .font(.h3)
                            .cornerRadius(12)
                    })
                    .padding(.horizontal, 28)
                    .padding(.bottom, 18)
                    .fullScreenCover(
                      isPresented: viewStore.binding(
                        get: { $0.isRunningTimerPresented },
                        send: QuickTimerAction.setRunningTimer(isPresented:)
                      )
                    ) {
                        RunningTimerView(store: self.store.scope(state: \.runningTimerState, action: QuickTimerAction.runningTimerAction))
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .gesture(
            DragGesture()
                .onChanged { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<QuickTimerState, QuickTimerAction>(
            initialState: QuickTimerState(),
            reducer: quickTimerReducer,
            environment: QuickTimerEnvironment(
                uuid: UUID.init,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                soundClient: .mock
            )
        )
        
        return Group {
            QuickTimerView(store: store)
                .previewDevice(.iPhone11)
                .environment(\.colorScheme, .dark)

            QuickTimerView(store: store)
                .previewDevice(.iPhone8)
        }
    }
}
