import UIKit
import SwiftUI

public extension UIImage {
  convenience init(namedSharedAsset name: String) {
    self.init(named: name, in: Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutCore"), compatibleWith: nil)!
  }
}

public extension Image {
    init(namedSharedAsset name: String) {
        self.init(uiImage: UIImage(namedSharedAsset: name))
    }
}
