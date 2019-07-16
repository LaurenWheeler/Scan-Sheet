import UIKit
extension UIViewController {
  func add(childViewController: UIViewController) {
    childViewController.willMove(toParent: self)
    addChild(childViewController)
    view.addSubview(childViewController.view)
    childViewController.didMove(toParent: self)
  }
}
