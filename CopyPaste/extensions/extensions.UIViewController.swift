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
}

protocol DisposableViewController {
  func removeReference()
}
