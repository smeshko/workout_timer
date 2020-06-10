import SwiftUI

public extension PreviewDevice {
    static let iPhone8 = PreviewDevice(rawValue: "iPhone 8")
    static let iPadPro = PreviewDevice(rawValue: "iPad Pro (11-inch)")
    static let iPhone11 = PreviewDevice(rawValue: "iPhone 11")
    static let iPhone11Pro = PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)")
}

/// Overrides the device for a preview.
///
/// If `nil` (default), Xcode will automatically pick an appropriate device
/// based on your target.
///
/// The following values are supported:
///
///     "Mac"
///     "iPhone 7"
///     "iPhone 7 Plus"
///     "iPhone 8"
///     "iPhone 8 Plus"
///     "iPhone SE"
///     "iPhone X"
///     "iPhone Xs"
///     "iPhone Xs Max"
///     "iPhone Xʀ"
///     "iPad mini 4"
///     "iPad Air 2"
///     "iPad Pro (9.7-inch)"
///     "iPad Pro (12.9-inch)"
///     "iPad (5th generation)"
///     "iPad Pro (12.9-inch) (2nd generation)"
///     "iPad Pro (10.5-inch)"
///     "iPad (6th generation)"
///     "iPad Pro (11-inch)"
///     "iPad Pro (12.9-inch) (3rd generation)"
///     "iPad mini (5th generation)"
///     "iPad Air (3rd generation)"
///     "Apple TV"
///     "Apple TV 4K"
///     "Apple TV 4K (at 1080p)"
///     "Apple Watch Series 2 - 38mm"
///     "Apple Watch Series 2 - 42mm"
///     "Apple Watch Series 3 - 38mm"
///     "Apple Watch Series 3 - 42mm"
///     "Apple Watch Series 4 - 40mm"
///     "Apple Watch Series 4 - 44mm"
