import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct WorkoutsFeedView: View {
    
    let store: Store<WorkoutsFeedState, WorkoutsFeedAction>
    
    public init(store: Store<WorkoutsFeedState, WorkoutsFeedAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                VStack {
                    WithViewStore(self.store.scope(state: \.selectedCategory, action: WorkoutsFeedAction.workoutCategoryChanged)) { workoutTypeViewStore in
                        
                        Picker("Types", selection: workoutTypeViewStore.binding(send: { $0 })) {
                            ForEach(viewStore.categories, id: \.id) { category in
                                Text(category.name).tag(category)
                            }
                        }
                        .padding([.leading, .trailing])
                        .labelsHidden()
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    WorkoutsListView(workouts: viewStore.selectedCategory.workouts)
                        .navigationBarItems(trailing: EmptyView())
                    Spacer()
                }
                .onAppear {
                    viewStore.send(.beginNavigation)
                }
            }
            .navigationBarTitle("Workouts")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.primary)
    }
}

struct WorkoutsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsFeedView(
            store: Store<WorkoutsFeedState, WorkoutsFeedAction>(
                initialState: WorkoutsFeedState(),
                reducer: workoutsFeedReducer,
                environment: WorkoutsFeedEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
    }
}
