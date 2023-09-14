import UIKit

class ModalPresentationController: UIPresentationController {

  private(set) lazy var blure: UIView = {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = 0.3
    return blurEffectView
  }()
  var inset: CGFloat = 0

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }
    containerView.insertSubview(blure, at: 0)
    containerView.addConstraintsWithFormat("V:|[v0]|", views: blure)
    containerView.addConstraintsWithFormat("H:|[v0]|", views: blure)

    guard let coordinator = presentedViewController.transitionCoordinator else {
      blure.alpha = 1.0
      return
    }

    coordinator.animate(alongsideTransition: { _ in
      self.blure.alpha = 1.0
    })
  }

  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      blure.alpha = 0.0
      return
    }

    if !coordinator.isInteractive {
      coordinator.animate(alongsideTransition: { _ in
        self.blure.alpha = 0.0
      })
    }
  }

  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = containerView, let presentedView = presentedView else { return .zero }

    let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)

    let targetWidth = safeAreaFrame.width - 2 * inset
    let fittingSize = CGSize(
      width: targetWidth,
      height: UIView.layoutFittingCompressedSize.height
    )

    let targetHeight = presentedView.systemLayoutSizeFitting(
      fittingSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    ).height
    var frame = safeAreaFrame
    frame.origin.x += inset
    frame.origin.y = containerView.frame.height - presentedView.frame.height
    frame.size.width = targetWidth
    frame.size.height = targetHeight > 200 ? targetHeight : containerView.frame.height

    return frame
  }
}
