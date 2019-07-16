import UIKit
extension UIViewController {    
    func add(viewController: UIViewController, toView: UIView) {
        addChild(viewController)
        viewController.view.frame = toView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    func remove(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIViewController {
    func transition(to child: UIViewController, completion: ((Bool) -> Void)? = nil) {
        let duration = 0.3
        let current = children.last
        addChild(child)
        let newView = child.view!
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newView.frame = view.bounds
        if let existing = current {
            existing.willMove(toParent: nil)
            transition(from: existing, to: child, duration: duration, options: [.transitionCrossDissolve], animations: { }, completion: { finished in
                existing.removeFromParent()
                child.didMove(toParent: self)
                completion?(finished)
            })
        } else {
            view.addSubview(newView)
            UIView.animate(withDuration: duration, delay: 0, options: [.transitionCrossDissolve], animations: { }, completion: { finished in
                child.didMove(toParent: self)
                completion?(finished)
            })
        }
    }
}
