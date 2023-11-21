//
//  extensions.UIViewController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
extension UIViewController {

  class func instantiate<T: UIViewController>() -> T? {

    let storyboard = UIStoryboard(
      name: String(describing: String(describing: self).replacingOccurrences(of: "ViewController", with: "")),
      bundle: nil
    )
    let identifier = String(describing: self)

    return storyboard.instantiateViewController(withIdentifier: identifier) as? T
  }

  static func loadFromNib() -> Self {

    func instantiateFromNib<T: UIViewController>() -> T {
      return T.init(nibName: String(describing: T.self), bundle: nil)
    }
    return instantiateFromNib()
  }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
  public func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting)
  }
  
  enum InteractiveDismissalType {
    case none
    case standard(useSwipeForDispose: Bool)
  }
  
  func present(
    _ viewController: any CustomPresentable,
    interactiveDismissalType: InteractiveDismissalType,
    completion: (() -> Void)? = nil
  ) {
    let interactionController: InteractionControlling?
    switch interactiveDismissalType {
      case .none:
        interactionController = nil
      case .standard(let useSwipe) :
        interactionController = StandardInteractionController(viewController: viewController, useSwipe: useSwipe)
    }
    
    let transitionManager = ModalTransitionManager(interactionController: interactionController)
    viewController.transitionManager = transitionManager
    viewController.transitioningDelegate = transitionManager
    viewController.modalPresentationStyle = .custom
    present(viewController, animated: true, completion: completion)
  }
}

protocol DisposableViewController {
  func removeReference()
}

