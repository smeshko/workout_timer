import SwiftUI

struct TimerView: View {
    
    @ObservedObject var viewModel = TimerViewModel()
        
    var body: some View {
        VStack {
            Spacer()
            
            Text(viewModel.timeLeft)
                .font(Font.system(size: 72, design: .monospaced))
            
            Spacer()
            
            VStack {
                TextField("working", text: $viewModel.workoutTime)
                TextField("break", text: $viewModel.breakTime)
                TextField("sets", text: $viewModel.sets)
                
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
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
