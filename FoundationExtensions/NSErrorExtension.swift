import UIKit
extension NSError {
    convenience init(code: Int, message: String) {
        self.init(domain: Bundle.main.bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
