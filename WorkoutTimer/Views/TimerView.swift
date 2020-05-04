import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel = TimerViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(viewModel.timeLeft)
                .font(Font.system(size: 48, design: .monospaced))
            
            Text(viewModel.currentSegmentTimeLeft)
                .font(Font.system(size: 72, design: .monospaced))
            
            Spacer()

            VStack {
                Slider(value: $viewModel.sets, inputType: .sets)
                Slider(value: $viewModel.workoutTime, inputType: .workout)
                Slider(value: $viewModel.breakTime, inputType: .pause)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                self.viewModel.begin()
            }) {
                Text("Begin!")
            }
            .padding()
        }
        .keyboardAdaptive()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
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
