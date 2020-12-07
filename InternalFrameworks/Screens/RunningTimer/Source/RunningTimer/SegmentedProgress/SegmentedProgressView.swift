import SwiftUI
import CoreInterface
import ComposableArchitecture

public struct SegmentedProgressView: View {
    private let store: Store<SegmentedProgressState, SegmentedProgressAction>

    let color: Color

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(store: Store<SegmentedProgressState, SegmentedProgressAction>, color: Color) {
        self.store = store
        self.color = color
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                if let title = viewStore.currentSegment?.setsProgress {
                    Text("Current set: \(title)")
                        .lineLimit(1)
                        .font(.bodySmall)
                        .foregroundColor(.appGrey)
                        .padding(.bottom, Spacing.xs)
                }
                HStack(alignment: .bottom, spacing: Spacing.xxs) {
                    ForEach(viewStore.segments, id: \.id) { segment in
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: CornerRadius.s)
                                    .foregroundColor(.appGrey)
                                RoundedRectangle(cornerRadius: CornerRadius.s)
                                    .foregroundColor(color)
                                    .frame(width: min(CGFloat(segment.progress) * proxy.size.width, proxy.size.width))
                                    .animation(.default)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            .onChange(of: horizontalSizeClass, perform: { value in
                viewStore.send(.onChangeSizeClass(isCompact: value == .compact))
            })
        }
    }
}

struct SegmentedProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let compactStore = Store<SegmentedProgressState, SegmentedProgressAction>(
            initialState: SegmentedProgressState(
                isCompact: true,
                segments: [mockSegment1, mockSegment2]
            ),
            reducer: segmentedProgressReducer,
            environment: SegmentedProgressEnvironment()
        )

        let regularStore = Store<SegmentedProgressState, SegmentedProgressAction>(
            initialState: SegmentedProgressState(
                isCompact: false,
                segments: [mockSegment1, mockSegment2]
            ),
            reducer: segmentedProgressReducer,
            environment: SegmentedProgressEnvironment()
        )

        return Group {
            SegmentedProgressView(store: compactStore, color: .appSuccess)
                .previewDevice(.iPhone11)
                .padding()

            SegmentedProgressView(store: regularStore, color: .appSuccess)
                .previewDevice(.iPadPro)
                .padding()

        }
    }
}
