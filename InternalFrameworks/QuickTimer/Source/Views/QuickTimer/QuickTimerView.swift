import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct QuickTimerView: View {
    
    @State private var isPresented = false

    let store: Store<QuickTimerState, QuickTimerAction>
    
    public init(store: Store<QuickTimerState, QuickTimerAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                VStack {
                    Spacer()

                    QuickExerciseBuilderView(store: self.store.scope(state: \.circuitPickerState, action: QuickTimerAction.circuitPickerUpdatedValues))
                        .padding()

                    Spacer()

                    Button(action: {
                        self.isPresented.toggle()
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
                    .fullScreenCover(isPresented: $isPresented, content: {
                        RunningTimerView(store: self.store.scope(state: \.runningTimerState, action: QuickTimerAction.runningTimerAction))
                    })
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)

            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
                .previewDevice(.iPhone8)
            
            QuickTimerView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
            
        }
    }
}
