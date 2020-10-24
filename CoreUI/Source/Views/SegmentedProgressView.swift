import SwiftUI

public struct SegmentedProgressView: View {
    let totalSegments: Int
    let filledSegments: Int
    let title: String?
    let color: Color

    public init(totalSegments: Int, filledSegments: Int, title: String? = nil, color: Color) {
        assert(totalSegments >= filledSegments, "Total segments should be more than or equal to filled segments")
        self.totalSegments = totalSegments
        self.filledSegments = filledSegments
        self.title = title
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
                    .font(.bodySmall)
                    .foregroundColor(.appGrey)
                    .padding(.bottom, 8)
            }
            HStack(spacing: 4) {
                ForEach(0 ..< filledSegments, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .foregroundColor(color)
                }

                ForEach(0 ..< totalSegments - filledSegments, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .foregroundColor(.appGrey)
                }
            }
            .frame(height: 4)
        }
    }
}

struct SegmentedProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedProgressView(totalSegments: 26, filledSegments: 17, title: "Round 1", color: .appSecondary)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
