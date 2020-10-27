import UIKit
import SwiftUI

public extension UIImage {
  convenience init(namedSharedAsset name: String) {
    self.init(named: name, in: Bundle(identifier: "com.tsonev.mobile.ios.CoreInterface"), compatibleWith: nil)!
  }
}

public extension Image {
    init(namedSharedAsset name: String) {
        self.init(uiImage: UIImage(namedSharedAsset: name))
    }
}
