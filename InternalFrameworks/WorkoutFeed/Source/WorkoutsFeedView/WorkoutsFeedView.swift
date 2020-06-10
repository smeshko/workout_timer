import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct WorkoutsFeedView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    let store: Store<WorkoutsFeedState, WorkoutsFeedAction>
    
    public init(store: Store<WorkoutsFeedState, WorkoutsFeedAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                Group {
                    if self.horizontalSizeClass == .regular {
                        ScrollView {
                            ForEach(viewStore.categories, id: \.id) { category in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.name)
                                        .padding()
                                        .font(.system(size: 16, weight: .semibold))
                                    WorkoutsListView(workouts: category.workouts)
                                }
                            }
                        }
                        .edgesIgnoringSafeArea(.leading)
                    } else {
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
                            Spacer()
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .overlay(ActivityIndicator(isAnimating: viewStore.binding(get: \.isLoading, send: WorkoutsFeedAction.loadingIndicatorStoppedLoading)))
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

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
