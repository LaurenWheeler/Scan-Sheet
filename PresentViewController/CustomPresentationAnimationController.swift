import UIKit
class CustomPresentationAnimationController: NSObject {
    let isPresenting :Bool
    let duration :TimeInterval = 0.5
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        else {
            return
        }
        presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
        presentedControllerView.center.y -= transitionContext.containerView.bounds.size.height
        transitionContext.containerView.addSubview(presentedControllerView)
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            presentedControllerView.center.y += transitionContext.containerView.bounds.size.height
        }, completion: {(completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }
    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        else {
            return
        }
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            presentedControllerView.center.y += transitionContext.containerView.bounds.size.height
        }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
}
extension CustomPresentationAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext: transitionContext)
        }
        else {
            animateDismissalWithTransitionContext(transitionContext: transitionContext)
        }
    }
}
