import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    
    let store: Store<TimerState, TimerAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Spacer()
                
                Text(viewStore.formattedTotalTimeLeft)
                    .font(Font.system(size: 48, design: .monospaced))
                
                Text(viewStore.formattedSegmentTimeLeft)
                    .font(Font.system(size: 72, design: .monospaced))
                
                Spacer()
                
                VStack {
                    Slider(value: viewStore.binding(get: \.sets, send: TimerAction.changeSetsCount), inputType: .sets)
                    Slider(value: viewStore.binding(get: \.workoutTime, send: TimerAction.changeWorkoutTime), inputType: .workout)
                    Slider(value: viewStore.binding(get: \.breakTime, send: TimerAction.changeBreakTime), inputType: .pause)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewStore.send(.start)
                }) {
                    Text("Begin!")
                }
                .disabled(viewStore.isRunning)
                .padding()
            }
        }
        .keyboardAdaptive()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            store: Store<TimerState, TimerAction>(
                initialState: TimerState(),
                reducer: timerReducer,
                environment: TimerEnvironment(soundClient: .mock)
            )
        )
    }
}

private enum InputType {
    case workout, pause, sets
    
    var sliderForegroundColor: Color {
        switch self {
            case .workout: return .red
            case .pause: return .blue
            case .sets: return .green
        }
    }
    
    var sliderBackgroundColor: Color {
        switch self {
            case .workout: return .green
            case .pause: return .red
            case .sets: return .blue
        }
    }
    
    var sliderTitle: String {
        switch self {
            case .workout: return "Workout Time"
            case .pause: return "Break Time"
            case .sets: return "Sets"
        }
    }
}



private struct Slider: View {
    
    @Binding var value: Int
    
    var inputType: InputType
    
    var body: some View {
        ZStack {
            TimerSlider(value: Binding(
                get: { Float(self.value) },
                set: { blah in self.value = Int(blah) }
            ))
                .sliderBackground(inputType.sliderBackgroundColor)
                .sliderForeground(inputType.sliderForegroundColor)
                .frame(height: 52)
            
            HStack {
                Text(inputType.sliderTitle)
                Spacer()
                Text("\(value)")
            }
            .padding()
        }
    }
}
