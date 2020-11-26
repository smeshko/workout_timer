import SwiftUI
import ComposableArchitecture
import QuickWorkoutForm

struct NoWorkoutsView: View {
    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @Binding private var isWorkoutFormPresented: Bool

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>, isWorkoutFormPresented: Binding<Bool>) {
        self.store = store
        self._isWorkoutFormPresented = isWorkoutFormPresented
    }

    var body: some View {
        VStack(spacing: 18) {
            Button(action: {
                isWorkoutFormPresented = true
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.appSuccess)
                        .frame(width: 125, height: 125)

                    Image(systemName: "plus")
                        .font(.gigantic)
                        .foregroundColor(.appWhite)
                }
            })
            Text("Create your first workout")
                .font(.h2)
                .foregroundColor(.appText)
        }
        .sheet(isPresented: $isWorkoutFormPresented) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct NoWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NoWorkoutsView(
            store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
                initialState: QuickWorkoutsListState(workouts: []),
                reducer: quickWorkoutsListReducer,
                environment: .preview
            ),
            isWorkoutFormPresented: .constant(false)
        )
    }
}
