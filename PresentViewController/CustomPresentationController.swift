import UIKit
class CustomPresentationController: UIPresentationController {
    lazy var dimmingView :UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.alpha = 0.0
        return view
    }()
    var presentedSize: CGSize = .zero
    override func presentationTransitionWillBegin() {
		guard
			let containerView = containerView,
            let presentedView = presentedView
		else {
			return
		}
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        presentedView.layer.masksToBounds = true
        presentedView.layer.cornerRadius = 10
        containerView.addSubview(presentedView)
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha = 1.0
            }, completion:nil)
        }
    }
    override func presentationTransitionDidEnd(_ completed: Bool)  {
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    override func dismissalTransitionWillBegin()  {
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.dimmingView.alpha  = 0.0
            }, completion:nil)
        }
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    override var frameOfPresentedViewInContainerView: CGRect {
		guard
			let containerView = containerView
		else {
			return CGRect()
		}
        var frame = containerView.bounds
        if presentedSize == .zero {
            frame = frame.insetBy(dx: 20, dy: 100)
        }
        else {
            let dx = (frame.width - presentedSize.width)/2
            let dy = (frame.height - presentedSize.height)/2
            frame = frame.insetBy(dx: dx, dy: dy)
        }
        return frame
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
		guard
			let containerView = containerView
		else {
			return
		}
        coordinator.animate(alongsideTransition: {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.dimmingView.frame = containerView.bounds
        }, completion:nil)
    }
}
