import UIKit
extension UIImage {
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
@available(iOS 10.0, *)
extension UIImage {
    func rendereredImage(size outputSize: CGSize, action: (UIGraphicsImageRendererContext) -> Void) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        return renderer.image(actions: { (context) in
            action(context)
            let bounds = context.format.bounds
            let rect = CGRect(x: (bounds.size.width - size.width)/2, y: (bounds.size.height - size.height)/2, width: size.width, height: size.height)
            self.draw(in: rect)
        })
    }
}
enum FlagStyle: Int {
    case none
    case roundedRect
    case square
    case circle
    public var size: CGSize {
        switch self {
        case .none, .roundedRect:
            return CGSize(width: 21, height: 15)
        case .square, .circle:
            return CGSize(width: 15, height: 15)
        }
    }
}
@available(iOS 10.0, *)
extension UIImage {
    func image(style: FlagStyle) -> UIImage {
        return self.rendereredImage(size: style.size, action: { (context) in
            switch style {
            case .none:
                break
            case .roundedRect:
                let path = UIBezierPath(roundedRect: context.format.bounds, cornerRadius: 2)
                path.addClip()
            case .square:
                let path = UIBezierPath(rect: context.format.bounds)
                path.addClip()
            case .circle:
                let path = UIBezierPath(roundedRect: context.format.bounds, cornerRadius: style.size.width)
                path.addClip()
            }
        })
    }
}
