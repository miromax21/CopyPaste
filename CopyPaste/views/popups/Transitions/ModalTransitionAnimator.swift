import UIKit

class ModalTransitionAnimator: NSObject {

  private let presenting: Bool
  var from: CGPoint?
  init(presenting: Bool) {
    self.presenting = presenting
    super.init()
  }
}

extension ModalTransitionAnimator: UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    presenting
    ? animatePresentation(using: transitionContext)
    : animateDismissal(using: transitionContext)
  }

  private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
    let presentedViewController = transitionContext.viewController(forKey: .to)!
    transitionContext.containerView.addSubview(presentedViewController.view)

    let presentedFrame = transitionContext.finalFrame(for: presentedViewController)
    let dismissedFrame = CGRect(
      x: from?.x ?? presentedFrame.minX,
      y: from?.y ?? transitionContext.containerView.bounds.height,
      width: presentedFrame.width,
      height: presentedFrame.height
    )

    presentedViewController.view.frame = dismissedFrame
    let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 1.0) {
      presentedViewController.view.frame = presentedFrame
    }
    animator.addCompletion { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    animator.startAnimation()
  }

  private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
    let presentedViewController = transitionContext.viewController(forKey: .from)!
    let presentedFrame = transitionContext.finalFrame(for: presentedViewController)
    let dismissedFrame = CGRect(
      x: from?.x ?? presentedFrame.minX,
      y: from?.y ?? transitionContext.containerView.bounds.height,
      width: presentedFrame.width,
      height: presentedFrame.height
    )
    let animator = UIViewPropertyAnimator(
      duration: transitionDuration(using: transitionContext),
      dampingRatio: 1.0
    ) {
      presentedViewController.view.frame = dismissedFrame
    }
    animator.addCompletion { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    animator.startAnimation()
  }
}
