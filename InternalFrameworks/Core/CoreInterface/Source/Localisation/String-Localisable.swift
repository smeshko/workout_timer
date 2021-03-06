import Foundation
import SwiftUI

class LocalizationBundleSource {}

public extension Text {
    init(key: LocalizedStringKey) {
        self.init(key, tableName: nil, bundle: Bundle(for: LocalizationBundleSource.self), comment: nil)
    }
}

public extension Button where Label == Text {
    init(key: LocalizedStringKey, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(key: key)
        }
    }
}

public extension Label where Title == Text, Icon == Image {
    init(key: String, systemImage: String) {
        self.init(key.localized, systemImage: systemImage)
    }
}

public extension String {

    func localized(_ count: Int) -> String {
        String(format: localized, count)
    }

    var localized: String {

        let translation = Bundle.main.localizedString(forKey: self, value: nil, table: nil)

        guard translation == self else {
            return translation
        }

        return localizedFromTable(bundle: Bundle(for: LocalizationBundleSource.self))
    }

    func localized(from bundle: Bundle) -> String {
        let translation = bundle.localizedString(forKey: self, value: nil, table: nil)

        guard translation == self else {
            return translation
        }

        return localizedFromTable(bundle: bundle)
    }

    func localizedFromTable(bundle: Bundle = Bundle.main, table: String? = nil) -> String {
        let translation = bundle.localizedString(forKey: self, value: nil, table: nil)
        let key = self

        guard translation == key,
            let path = bundle.path(forResource: "en", ofType: "lproj"),
            let defaultBundle = Bundle(path: path) else {
            return translation
        }

        return defaultBundle.localizedString(forKey: self, value: nil, table: nil)
    }
}
