import SwiftUI

public struct LevelView: View {

    let level: Int
    let showLabel: Bool

    public init(level: Int, showLabel: Bool) {
        self.level = level
        self.showLabel = showLabel
    }

    public var body: some View {
        HStack(spacing: 6) {

            if showLabel {
                Text("LEVEL")
                    .font(.label)
                    .tracking(1)
                    .foregroundColor(.appWhite)
            }

            HStack(spacing: 4) {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(.appSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 1 ? .appSecondary : .appTextSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 2 ? .appTextSecondary : .appTextSecondary)
            }
        }
    }
}
