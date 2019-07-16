import UIKit
extension UIColor {
    static let colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#16a085",
                        "#27ae60","#2980b9","#8e44ad","#2c3e50","#f1c40f","#e67e22",
                        "#e74c3c","#95a5a6","#f39c12","#d35400","#c0392b","#bdc3c7",
                        "#7f8c8d","#96281B","#EF4836","#DB0A5B","#F64747","#F1A9A0",
                        "#D2527F","#E08283","#F62459","#E26A6A","#663399","#674172",
                        "#913D88","#8E44AD","#9B59B6","#446CB3","#4183D7","#59ABE3",
                        "#81CFE0","#3498DB","#2C3E50","#336E7B","#22313F","#1E8BC3",
                        "#3A539B","#34495E","#2574A9","#4B77BE","#26A65B","#1BA39C",
                        "#16A085","#049372","#F4D03F","#F89406","#D35400","#F2784B"];
    static func randomByString(_ string: String) -> UIColor {
        let num = abs(string.hashValue % 54)
        return UIColor(hex:colors[num])
    }
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            fatalError("Hex format must have form #XXXXXX")
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "#%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}
extension UIColor {
    func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = CGFloat(fRed * 255.0)
            let iGreen = CGFloat(fGreen * 255.0)
            let iBlue = CGFloat(fBlue * 255.0)
            let iAlpha = CGFloat(fAlpha * 255.0)
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            return nil
        }
    }
}
extension UIColor {
    func grayscale() -> UIColor {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return UIColor.init(white: 0.299*fRed + 0.587*fGreen + 0.114*fBlue, alpha: fAlpha)
        } else {
            return self
        }
    }
}
extension UIColor {
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent));
    }
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent));
    }
    func colorWithBrightnessFactor(_ factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
    func lighter(by percentage:CGFloat=30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    func darker(by percentage:CGFloat=30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    func adjust(by percentage:CGFloat=30.0) -> UIColor {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return self
        }
    }
}
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var hex = hex.replacingOccurrences(of: "#", with: "")
        guard hex.count == 3 || hex.count == 6 else {
            fatalError("Hex characters must be either 3 or 6 characters")
        }
        if hex.count == 3 {
            let tmp = hex
            hex = ""
            for c in tmp {
                hex += String([c,c])
            }
        }
        let scanner = Scanner(string: hex)
        var rgb: UInt32 = 0
        scanner.scanHexInt32(&rgb)
        let R = CGFloat((rgb >> 16) & 0xFF)/255
        let G = CGFloat((rgb >> 8) & 0xFF)/255
        let B = CGFloat(rgb & 0xFF)/255
        self.init(red: R, green: G, blue: B, alpha: alpha)
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        if (1 < r) || (1 < g) || (1 < b) {
            self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
        } else {
            self.init(red: r, green: g, blue: b, alpha: a)
        }
    }
    convenience init(h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat = 1) {
        if (1 < h) || (1 < s) || (1 < b) {
            self.init(hue: h/360, saturation: s/100, brightness: b/100, alpha: a)
        } else {
            self.init(hue: h, saturation: s, brightness: b, alpha: a)
        }
    }
    class func black() -> UIColor {
        return UIColor(r: 0, g: 0, b: 0, a: 1)
    }
    class func white() -> UIColor {
        return UIColor(r: 1, g: 1, b: 1, a: 1)
    }
    class func random() -> UIColor {
        let H = CGFloat(arc4random_uniform(360))
        let S = CGFloat(arc4random_uniform(30) + 70)
        let B = CGFloat(arc4random_uniform(50) + 30)
        return UIColor(h: H, s: S, b: B, a: 1)
    }
    func isEqual(to color: UIColor, strict: Bool = true) -> Bool {
        if strict {
            return self.isEqual(color)
        } else {
            let RGBA = self.RGBA
            let other = color.RGBA
            let margin = CGFloat(0.01)
            func comp(a: CGFloat, b: CGFloat) -> Bool {
                return abs(b-a) <= (a*margin)
            }
            return comp(a: RGBA[0], b: other[0]) && comp(a: RGBA[1], b: other[1]) && comp(a: RGBA[2], b: other[2]) && comp(a: RGBA[3], b: other[3])
        }
    }
    var RGBA: [CGFloat] {
        var R: CGFloat = 0
        var G: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 0
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        return [R,G,B,A]
    }
    var RGBA_8Bit: [CGFloat] {
        let RGBA = self.RGBA
        return [round(RGBA[0] * 255), round(RGBA[1] * 255), round(RGBA[2] * 255), RGBA[3]]
    }
    var HSBA: [CGFloat] {
        var H: CGFloat = 0
        var S: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 0
        self.getHue(&H, saturation: &S, brightness: &B, alpha: &A)
        return [H,S,B,A]
    }
    var HSBA_8Bit: [CGFloat] {
        let HSBA = self.HSBA
        return [round(HSBA[0] * 360), round(HSBA[1] * 100), round(HSBA[2] * 100), HSBA[3]]
    }
    var XYZ: [CGFloat] {
        let RGBA = self.RGBA
        func XYZ_helper(c: CGFloat) -> CGFloat {
            return (0.04045 < c ? pow((c + 0.055)/1.055, 2.4) : c/12.92) * 100
        }
        let R = XYZ_helper(c: RGBA[0])
        let G = XYZ_helper(c: RGBA[1])
        let B = XYZ_helper(c: RGBA[2])
        let X: CGFloat = (R * 0.4124) + (G * 0.3576) + (B * 0.1805)
        let Y: CGFloat = (R * 0.2126) + (G * 0.7152) + (B * 0.0722)
        let Z: CGFloat = (R * 0.0193) + (G * 0.1192) + (B * 0.9505)
        return [X, Y, Z]
    }
    var LAB: [CGFloat] {
        let XYZ = self.XYZ
        func LAB_helper(c: CGFloat) -> CGFloat {
            return 0.008856 < c ? pow(c, 1/3) : ((7.787 * c) + (16/116))
        }
        let X: CGFloat = LAB_helper(c: XYZ[0]/95.047)
        let Y: CGFloat = LAB_helper(c: XYZ[1]/100.0)
        let Z: CGFloat = LAB_helper(c: XYZ[2]/108.883)
        let L: CGFloat = (116 * Y) - 16
        let A: CGFloat = 500 * (X - Y)
        let B: CGFloat = 200 * (Y - Z)
        return [L, A, B]
    }
    var luminance: CGFloat {
        let RGBA = self.RGBA
        func lumHelper(c: CGFloat) -> CGFloat {
            return (c < 0.03928) ? (c/12.92): pow((c+0.055)/1.055, 2.4)
        }
        return 0.2126 * lumHelper(c: RGBA[0]) + 0.7152 * lumHelper(c: RGBA[1]) + 0.0722 * lumHelper(c: RGBA[2])
    }
    var isDark: Bool {
        return self.luminance < 0.5
    }
    var isLight: Bool {
        return !self.isDark
    }
    func isDarker(than color: UIColor) -> Bool {
        return self.luminance < color.luminance
    }
    func isLighter(than color: UIColor) -> Bool {
        return !self.isDarker(than: color)
    }
    var isBlackOrWhite: Bool {
        let RGBA = self.RGBA
        let isBlack = RGBA[0] < 0.09 && RGBA[1] < 0.09 && RGBA[2] < 0.09
        let isWhite = RGBA[0] > 0.91 && RGBA[1] > 0.91 && RGBA[2] > 0.91
        return isBlack || isWhite
    }
    func CIE94(compare color: UIColor) -> CGFloat {
        let k_L:CGFloat = 1
        let k_C:CGFloat = 1
        let k_H:CGFloat = 1
        let k_1:CGFloat = 0.045
        let k_2:CGFloat = 0.015
        let LAB1 = self.LAB
        let L_1 = LAB1[0], a_1 = LAB1[1], b_1 = LAB1[2]
        let LAB2 = color.LAB
        let L_2 = LAB2[0], a_2 = LAB2[1], b_2 = LAB2[2]
        let deltaL:CGFloat = L_1 - L_2
        let deltaA:CGFloat = a_1 - a_2
        let deltaB:CGFloat = b_1 - b_2
        let C_1:CGFloat = sqrt(pow(a_1, 2) + pow(b_1, 2))
        let C_2:CGFloat = sqrt(pow(a_2, 2) + pow(b_2, 2))
        let deltaC_ab:CGFloat = C_1 - C_2
        let deltaH_ab:CGFloat = sqrt(pow(deltaA, 2) + pow(deltaB, 2) - pow(deltaC_ab, 2))
        let s_L:CGFloat = 1
        let s_C:CGFloat = 1 + (k_1 * C_1)
        let s_H:CGFloat = 1 + (k_2 * C_1)
        let P1:CGFloat = pow(deltaL/(k_L * s_L), 2)
        let P2:CGFloat = pow(deltaC_ab/(k_C * s_C), 2)
        let P3:CGFloat = pow(deltaH_ab/(k_H * s_H), 2)
        return sqrt((P1.isNaN ? 0:P1) + (P2.isNaN ? 0:P2) + (P3.isNaN ? 0:P3))
    }
    func CIEDE2000(compare color: UIColor) -> CGFloat {
        func rad2deg(r: CGFloat) -> CGFloat {
            return r * CGFloat(180/Double.pi)
        }
        func deg2rad(d: CGFloat) -> CGFloat {
            return d * CGFloat(Double.pi/180)
        }
        let k_l = CGFloat(1), k_c = CGFloat(1), k_h = CGFloat(1)
        let LAB1 = self.LAB
        let L_1 = LAB1[0], a_1 = LAB1[1], b_1 = LAB1[2]
        let LAB2 = color.LAB
        let L_2 = LAB2[0], a_2 = LAB2[1], b_2 = LAB2[2]
        let C_1ab = sqrt(pow(a_1, 2) + pow(b_1, 2))
        let C_2ab = sqrt(pow(a_2, 2) + pow(b_2, 2))
        let C_ab  = (C_1ab + C_2ab)/2
        let G = 0.5 * (1 - sqrt(pow(C_ab, 7)/(pow(C_ab, 7) + pow(25, 7))))
        let a_1_p = (1 + G) * a_1
        let a_2_p = (1 + G) * a_2
        let C_1_p = sqrt(pow(a_1_p, 2) + pow(b_1, 2))
        let C_2_p = sqrt(pow(a_2_p, 2) + pow(b_2, 2))
        let h_1_p = (b_1 == 0 && a_1_p == 0) ? 0 : (atan2(b_1, a_1_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)
        let h_2_p = (b_2 == 0 && a_2_p == 0) ? 0 : (atan2(b_2, a_2_p) + CGFloat(2 * Double.pi)) * CGFloat(180/Double.pi)
        let deltaL_p = L_2 - L_1
        let deltaC_p = C_2_p - C_1_p
        var h_p: CGFloat = 0
        if (C_1_p * C_2_p) == 0 {
            h_p = 0
        } else if abs(h_2_p - h_1_p) <= 180 {
            h_p = h_2_p - h_1_p
        } else if (h_2_p - h_1_p) > 180 {
            h_p = h_2_p - h_1_p - 360
        } else if (h_2_p - h_1_p) < -180 {
            h_p = h_2_p - h_1_p + 360
        }
        let deltaH_p = 2 * sqrt(C_1_p * C_2_p) * sin(deg2rad(d: h_p/2))
        let L_p = (L_1 + L_2)/2
        let C_p = (C_1_p + C_2_p)/2
        var h_p_bar: CGFloat = 0
        if (h_1_p * h_2_p) == 0 {
            h_p_bar = h_1_p + h_2_p
        } else if abs(h_1_p - h_2_p) <= 180 {
            h_p_bar = (h_1_p + h_2_p)/2
        } else if abs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) < 360 {
            h_p_bar = (h_1_p + h_2_p + 360)/2
        } else if abs(h_1_p - h_2_p) > 180 && (h_1_p + h_2_p) >= 360 {
            h_p_bar = (h_1_p + h_2_p - 360)/2
        }
        let T1 = cos(deg2rad(d: h_p_bar - 30))
        let T2 = cos(deg2rad(d: 2 * h_p_bar))
        let T3 = cos(deg2rad(d: (3 * h_p_bar) + 6))
        let T4 = cos(deg2rad(d: (4 * h_p_bar) - 63))
        let T = 1 - rad2deg(r: 0.17 * T1) + rad2deg(r: 0.24 * T2) - rad2deg(r: 0.32 * T3) + rad2deg(r: 0.20 * T4)
        let deltaTheta = 30 * exp(-pow((h_p_bar - 275)/25, 2))
        let R_c = 2 * sqrt(pow(C_p, 7)/(pow(C_p, 7) + pow(25, 7)))
        let S_l =  1 + ((0.015 * pow(L_p - 50, 2))/sqrt(20 + pow(L_p - 50, 2)))
        let S_c = 1 + (0.045 * C_p)
        let S_h = 1 + (0.015 * C_p * T)
        let R_t = -sin(deg2rad(d: 2 * deltaTheta)) * R_c
        let P1 = deltaL_p/(k_l * S_l)
        let P2 = deltaC_p/(k_c * S_c)
        let P3 = deltaH_p/(k_h * S_h)
        let deltaE = sqrt(pow(P1, 2) + pow(P2, 2) + pow(P3, 2) + (R_t * P2 * P3))
        return deltaE
    }
    func contrastRatio(with color: UIColor) -> CGFloat {
        let L1 = self.luminance
        let L2 = color.luminance
        if L1 < L2 {
            return (L2 + 0.05)/(L1 + 0.05)
        } else {
            return (L1 + 0.05)/(L2 + 0.05)
        }
    }
    func isContrasting(with color: UIColor, strict: Bool = false) -> Bool {
        let ratio = self.contrastRatio(with: color)
        return strict ? (7 <= ratio) : (4.5 < ratio)
    }
    var fullContrastColor: UIColor {
        let RGBA = self.RGBA
        let delta = (0.299*RGBA[0]) + (0.587*RGBA[1]) + (0.114*RGBA[2])
        return 0.5 < delta ? UIColor.black() : UIColor.white()
    }
    func withAlpha(newAlpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(newAlpha)
    }
    func overlay(with color: UIColor) -> UIColor {
        let mainRGBA = self.RGBA
        let maskRGBA = color.RGBA
        func masker(a: CGFloat, b: CGFloat) -> CGFloat {
            if a < 0.5 {
                return 2 * a * b
            } else {
                return 1-(2*(1-a)*(1-b))
            }
        }
        return UIColor(
            r: masker(a: mainRGBA[0], b: maskRGBA[0]),
            g: masker(a: mainRGBA[1], b: maskRGBA[1]),
            b: masker(a: mainRGBA[2], b: maskRGBA[2]),
            a: masker(a: mainRGBA[3], b: maskRGBA[3])
        )
    }
    var overlayBlack: UIColor {
        return self.overlay(with: UIColor.black())
    }
    var overlayWhite: UIColor {
        return self.overlay(with: UIColor.white())
    }
    func multiply(with color: UIColor) -> UIColor {
        let mainRGBA = self.RGBA
        let maskRGBA = color.RGBA
        return UIColor(
            r: mainRGBA[0] * maskRGBA[0],
            g: mainRGBA[1] * maskRGBA[1],
            b: mainRGBA[2] * maskRGBA[2],
            a: mainRGBA[3] * maskRGBA[3]
        )
    }
    func screen(with color: UIColor) -> UIColor {
        let mainRGBA = self.RGBA
        let maskRGBA = color.RGBA
        func masker(a: CGFloat, b: CGFloat) -> CGFloat {
            return 1-((1-a)*(1-b))
        }
        return UIColor(
            r: masker(a: mainRGBA[0], b: maskRGBA[0]),
            g: masker(a: mainRGBA[1], b: maskRGBA[1]),
            b: masker(a: mainRGBA[2], b: maskRGBA[2]),
            a: masker(a: mainRGBA[3], b: maskRGBA[3])
        )
    }
    private func harmony(hueIncrement: CGFloat) -> UIColor {
        let HSBA = self.HSBA_8Bit
        let total = HSBA[0] + hueIncrement
        let newHue = abs(total.truncatingRemainder(dividingBy: 360.0))
        return UIColor(h: newHue, s: HSBA[1], b: HSBA[2], a: HSBA[3])
    }
    var complement: UIColor {
        return self.harmony(hueIncrement: 180)
    }
}
