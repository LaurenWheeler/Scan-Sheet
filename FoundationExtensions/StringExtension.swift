import UIKit
import CommonCrypto
extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
extension String {
    public func durationFromISO8601() -> (hours: Int, minutes: Int, seconds: Int) {
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0
        var str = uppercased()
        guard let timeRange = str.range(of: "T") else {
            return (hours: hours, minutes: minutes, seconds: seconds)
        }
        str = String(str[str.index(after: timeRange.lowerBound)...])
        let scanner = Scanner(string: str)
        var maxTry = 0
        while !scanner.isAtEnd {
            maxTry += 1
            if (maxTry > 3) {
                break
            }
            var num: NSString?
            scanner.scanCharacters(from: CharacterSet.decimalDigits, into: &num)
            var c: NSString?
            scanner.scanCharacters(from: CharacterSet.uppercaseLetters, into: &c)
            if c == "H" {
                hours = num?.integerValue ?? 0
            }
            else if c == "M" {
                minutes = num?.integerValue ?? 0
            }
            else if c == "S" {
                seconds = num?.integerValue ?? 0
            }
            else {
                break
            }
        }
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
    public func durationTimeFromISO8601() -> Int {
        let v = durationFromISO8601()
        return v.hours * 3600 + v.minutes * 60 + v.seconds
    }
    public func durationStringFromISO8601() -> String {
        let v = durationFromISO8601()
        if  v.hours > 0 {
            return String(format: "%02d:%02d:%02d", v.hours, v.minutes, v.seconds)
        }
        return String(format: "%02d:%02d", v.minutes, v.seconds)
    }
}
extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return String(format: hash as String)
    }
}
extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        guard let attributedString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString.string)
    }
}
extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
}
