import Foundation
extension FixedWidthInteger {
    public func toDigitalUnitForm() -> String {
        if self < 0 {
            return ""
        }
        else if self < 1_000 {
            return "\(self)"
        }
        else if self < 1_000_000 {
            return "\(Int(self / 1_000))K"
        }
        else if self < 1_000_000_000 {
            return "\(Int(self / 1_000_000))M"
        }
        else {
            return "\(Int(self / 1_000_000_000))B"
        }
    }
    public func toTimeForm() -> String {
        let hour = self / 3600
        let minute = (self - hour * 3600) / 60
        let second = (self - hour * 3600) - (minute * 60)
        let temp : String = "\(minute < 10 ? "0" : "")\(minute):\(second < 10 ? "0" : "")\(second)"
        if hour > 0 {
            return "\(hour):\(temp)"
        }
        else {
            return temp
        }
    }
}
