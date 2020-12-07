import SwiftUI

public struct Spacing {
    /// 0
    public static let none: CGFloat = 0
    /// 4
    public static let xxs: CGFloat = 4
    /// 8
    public static let xs: CGFloat = 8
    /// 12
    public static let s: CGFloat = 12
    /// 16
    public static let m: CGFloat = 16
    /// 18
    public static let l: CGFloat = 18
    /// 22
    public static let xl: CGFloat = 22
    /// 28
    public static let xxl: CGFloat = 28

    /// 8 for compact, 160 for regular
    public static func margin(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        guard let sizeClass = sizeClass else { return 8 }
        switch sizeClass {
        case .compact:
            return 8
        case .regular:
            return 160
        @unknown default:
            return 8
        }
    }
}
