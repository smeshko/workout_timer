import SwiftUI

public struct ProgressView: View {
    @Binding var value: Double
    private let axis: Axis
    private var fillColor: Color? = Color(.systemTeal)
    private var remainingColor: Color? = .clear
    
    public init(value: Binding<Double>, axis: Axis) {
        self._value = value
        self.axis = axis
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: self.axis == .horizontal ? .leading : .bottom) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(self.remainingColor)
                
                if self.axis == .horizontal {
                    Rectangle()
                        .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                        .foregroundColor(self.fillColor)
                        .animation(.linear)
                } else {
                    Rectangle()
                        .frame(width: geometry.size.width, height: min(CGFloat(self.value) * geometry.size.height, geometry.size.height))
                        .foregroundColor(self.fillColor)
                        .animation(.linear)

                }
            }
        }
    }
    
    public func fillColor(_ color: Color?) -> Self {
        var copy = self
        copy.fillColor = color
        return copy
    }
    
    public func remainingColor(_ color: Color?) -> Self {
        var copy = self
        copy.remainingColor = color
        return copy
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: Binding.constant(0.3), axis: .vertical)
    }
}
