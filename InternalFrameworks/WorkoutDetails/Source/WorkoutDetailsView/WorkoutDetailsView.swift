import SwiftUI
import WorkoutCore
import ComposableArchitecture

public struct WorkoutDetailsView: View {
    let store: Store<WorkoutDetailsState, WorkoutDetailsAction>
    @State private var isPresented = false

    public init(workout: Workout) {
        store = Store<WorkoutDetailsState, WorkoutDetailsAction>(
            initialState: WorkoutDetailsState(workout: workout),
            reducer: workoutDetailsReducer,
            environment: WorkoutDetailsEnvironment()
        )
    }

    public var body: some View {
        WithViewStore(store) { viewStore in

            HStack {
                InfoView(image: "clock.fill", title: "Duration", subtitle: "\(viewStore.workout.duration)m")
                Spacer()
                InfoView(image: "heart.fill", title: "Exercises", subtitle: "\(viewStore.workout.exerciseCount) Exercises")
                Spacer()
                LevelView(level: 2)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)

            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        ForEach(viewStore.workout.sets, id: \.name) { set in
                            if set.type != .rest {
                                ExerciseRowView(set: set)
                                    .padding(.bottom, 18)
                            }
                        }
                        .padding(.horizontal, 28)

                        Spacer()
                    }
                }

                Button(action: {
                    self.isPresented.toggle()
                }, label: {
                    Text("Start Now")
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
                    ActiveWorkoutView(workout: viewStore.workout)
                })
            }
            .navigationBarTitle(viewStore.workout.name, displayMode: .large)
        }
    }
}

struct WorkoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        return WorkoutDetailsView(workout: mockWorkout1)
            .colorScheme(.dark)
            .background(Color.black)
    }
}

private struct InfoView: View {

    private let image: String
    private let title: String
    private let subtitle: String

    init(image: String, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: image)
                .foregroundColor(.appPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bodySmall)
                    .foregroundColor(.appGrey)
                Text(subtitle)
                    .font(.h4)
                    .foregroundColor(.appWhite)
            }
        }
    }
}

private struct LevelView: View {

    private let level: Int

    init(level: Int) {
        self.level = level
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "shift.fill")
                .foregroundColor(.appPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Level")
                    .font(.bodySmall)
                    .foregroundColor(.appGrey)
                WorkoutCore.LevelView(level: level, showLabel: false)
            }
        }
    }
}

