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
                TextField("working", value: $viewModel.workoutTime, formatter: NumberFormatter())
                TextField("break", value: $viewModel.breakTime, formatter: NumberFormatter())
                TextField("sets", value: $viewModel.sets, formatter: NumberFormatter())
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
