import SwiftUI

public extension PreviewDevice {
    static let iPhone8 = PreviewDevice(rawValue: "iPhone 8")
    static let iPhone11 = PreviewDevice(rawValue: "iPhone 11")
    static let iPadPro = PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)")
    static let watch6 = PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm")
}

private extension PreviewDevice {
    var width: CGFloat {
        switch self.rawValue {
        case "iPhone 8": return 334
        case "iPhone 11": return 828
        case "iPad Pro (12.9-inch) (3rd generation)": return 2048
        default: return 0
        }
    }

    var height: CGFloat {
        switch self.rawValue {
        case "iPhone 8": return 750
        case "iPhone 11": return 1792
        case "iPad Pro (12.9-inch) (3rd generation)": return 2732
        default: return 0
        }
    }

    var scale: CGFloat {
        switch self.rawValue {
        case "iPhone 8": return 1
        case "iPhone 11": return 2
        case "iPad Pro (12.9-inch) (3rd generation)": return 2
        default: return 0
        }
    }
}

public extension PreviewLayout {
    static var landscape: PreviewLayout {
        .fixed(width: 2436 / 3.0, height: 1125 / 3.0)
    }

    static func landscape(_ device: PreviewDevice) -> PreviewLayout {
        .fixed(width: device.height / device.scale, height: device.width / device.scale)
    }
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
