import SwiftUI
import ComposableArchitecture

public struct TimerView: View {
  
  let store: Store<TimerState, TimerAction>
  
  public init(store: Store<TimerState, TimerAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Spacer()
        
        Text(viewStore.formattedTotalTimeLeft)
          .font(Font.system(size: 48, design: .monospaced))
        
        Text(viewStore.formattedSegmentTimeLeft)
          .font(Font.system(size: 72, design: .monospaced))
        
        Spacer()
        
        VStack(spacing: 16) {
          ValuePicker(
            store: Store<PickerState, PickerAction>(
              initialState: PickerState(value: 2),
              reducer: pickerReducer,
              environment: PickerEnvironment()
          ),
            valueName: "Sets",
            maxValue: 21
          )
          
          ValuePicker(
            store: Store<PickerState, PickerAction>(
              initialState: PickerState(value: 60),
              reducer: pickerReducer,
              environment: PickerEnvironment()
          ),
            valueName: "Workout Time",
            maxValue: 121
          )
          
          ValuePicker(
            store: Store<PickerState, PickerAction>(
              initialState: PickerState(value: 30),
              reducer: pickerReducer,
              environment: PickerEnvironment()
          ),
            valueName: "Break Time",
            maxValue: 61
          )

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
        environment: TimerEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          soundClient: .mock
        )
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

private struct MySlider: View {
  
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
