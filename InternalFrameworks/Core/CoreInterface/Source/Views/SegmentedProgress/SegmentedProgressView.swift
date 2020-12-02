import SwiftUI
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
                if let title = viewStore.title {
                    Text(title)
                        .lineLimit(1)
                        .font(.bodySmall)
                        .foregroundColor(.appGrey)
                        .padding(.bottom, Spacing.xs)
                }
                HStack(alignment: .bottom, spacing: Spacing.xxs) {
                    ForEach(0 ..< viewStore.filledSegments, id: \.self) { index in
                        VStack(alignment: .trailing) {
                            if viewStore.shouldShowLabels {
                                Text(label(forIndex: index, filled: true, store: viewStore))
                                    .font(.label)
                                    .foregroundColor(.appText)
                            }
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(color)
                                .frame(height: 4)
                        }
                    }

                    ForEach(0 ..< viewStore.leftSegments, id: \.self) { index in
                        VStack(alignment: .trailing) {
                            if viewStore.shouldShowLabels {
                                Text(label(forIndex: index, filled: false, store: viewStore))
                                    .font(.label)
                                    .foregroundColor(.appText)
                            }
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundColor(.appGrey)
                                .frame(height: 4)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: horizontalSizeClass, perform: { value in
                viewStore.send(.onChangeSizeClass(isCompact: value == .compact))
            })
        }
    }

    func label(forIndex index: Int, filled: Bool, store: ViewStore<SegmentedProgressState, SegmentedProgressAction>) -> String {
        if filled {
            return "\((index + 1) * store.segmentLabelModifier)"
        } else {
            if (index + 1) == store.leftSegments {
                return "\(store.originalTotalCount)"
            } else {
                return "\((index + 1 + store.filledSegments) * store.segmentLabelModifier)"
            }
        }
    }

}

struct SegmentedProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let compactStore = Store<SegmentedProgressState, SegmentedProgressAction>(
            initialState: SegmentedProgressState(
                totalSegments: 7,
                filledSegments: 4,
                title: "Some title",
                isCompact: true
            ),
            reducer: segmentedProgressReducer,
            environment: SegmentedProgressEnvironment()
        )

        let regularStore = Store<SegmentedProgressState, SegmentedProgressAction>(
            initialState: SegmentedProgressState(
                totalSegments: 19,
                filledSegments: 6,
                title: "Some title",
                isCompact: false
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
