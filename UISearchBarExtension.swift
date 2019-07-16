import UIKit
extension UISearchBar {
    var textField: UITextField? {
        return getViewElement(type: UITextField.self)
    }
    private func getViewElement<T>(type: T.Type) -> T? {
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    func setTextFieldColor(color: UIColor) {
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
            case .prominent, .default:
                textField.backgroundColor = color
            default:
                break
            }
        }
    }
}
