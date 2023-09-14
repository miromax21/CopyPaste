//
//  PresentationController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
protocol PresentableViewController: UIViewController {
  var complete: ((_ callBack: Any?) -> Void)? {get set}
  var presentSize: PresentSize? {get set}
}

final class PresentationController: UIPresentationController {
  let blurEffectView: UIVisualEffectView!
  var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
  var presentSize: PresentSize!  = .full

  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
    let blurEffect = UIBlurEffect(style: .dark)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.blurEffectView.isUserInteractionEnabled = true
    self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    self.presentSize = (presentedViewController as? PresentableViewController)?.presentSize ?? .full
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    var viewSizePercent: Double = 1.0
    if let size = presentSize?.size, (0...100).contains(size) {
      viewSizePercent = Double(size) / 100.0
    }
    let frame = self.containerView!.frame
    return CGRect(
      origin: CGPoint( x: 0, y: frame.height * (1.0 - viewSizePercent)),
      size: CGSize( width: frame.width, height: frame.height * viewSizePercent)
    )
  }

  override func presentationTransitionWillBegin() {
    self.blurEffectView.alpha = 0
    self.containerView?.addSubview(blurEffectView)
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
      self.blurEffectView.alpha = 0.7
    }, completion: { (_) in })
  }

  override func dismissalTransitionWillBegin() {
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
      self.blurEffectView.alpha = 0
    }, completion: { (_) in
      self.blurEffectView.removeFromSuperview()
    })
  }

  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    guard presentSize != .full else {
      return
    }
  }

  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
    blurEffectView.frame = containerView!.bounds
  }

  @objc func dismissController() {
    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
}
