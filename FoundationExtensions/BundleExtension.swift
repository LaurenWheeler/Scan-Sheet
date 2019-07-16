import Foundation
extension Bundle {
    var displayName: String {
        return infoDictionary?["CFBundleDisplayName"] as! String
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
}
