//
//  AppNavigationController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import UIKit
protocol ShowAlert {
  func next(viewController: UIViewController, animate: Bool)
}
final class AppNavigationController: UINavigationController, ShowAlert {

  // private(set) var presentedView: PresentableViewController?
  var mainScreen: UIViewController? {
    return viewControllers.first
  }

  var currentView: UIViewController? {
    return viewControllers.last
  }

  lazy var transitionAnimation: CATransition = {
    let transition = CATransition()
    transition.duration = 5.3
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    transition.type = .fade
    transition.subtype = .fromBottom
    return transition
  }()

  override func popViewController(animated: Bool) -> UIViewController? {
    return pop(transition: nil)?.last
  }

  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
    return false
  }

  func start(with viewController: UIViewController, animate: Bool = true) {
    if animate {
      view.layer.add(transitionAnimation, forKey: nil)
      pushViewController(viewController, animated: true)
    }
    viewControllers = [viewController]
    configure()
  }

  func next(coordinator: BaseCoordinator, animate: Bool = true) {
    configure()
    coordinator.start()
  }

  func next(viewController: UIViewController, animate: Bool = true) {
    configure()
    if animate {
      navigationController?.view.layer.add(transitionAnimation, forKey: nil)
    }
    pushViewController(viewController, animated: false)
    removeBackGesture()
  }

  func presentViewControllerModaly(
    next: CustomPresentable,
    presentCompletion: (() -> Void)? = nil,
    interactiveDismissalType: InteractiveDismissalType = .standard(useSwipeForDispose: true)
  ) {
    currentView?.present(
      next,
      interactiveDismissalType: interactiveDismissalType,
      completion: presentCompletion
    )
  }

  func pop(transition: UIView.AnimationTransition? = .flipFromRight) -> [UIViewController]? {
    if let view = currentView as? DisposableViewController {
      view.removeReference()
    }
    view.layer.add(transitionAnimation, forKey: nil)
    return popToRootViewController(animated: false)
  }

  func present(
    _ view: CustomPresentable,
    completion: ((_ callBack: Any?) -> Void)? = nil
  ) {
    let presentedView = view
    presentedView.completion = completion
    presentViewControllerModaly(next: presentedView)
  }

  func present(
    _ next: UIViewController,
    style: UIModalPresentationStyle = .custom,
    presentCompletion: (() -> Void)? = nil
  ) {
    next.transitioningDelegate = currentView
    next.modalPresentationStyle = style
    currentView?.present(next, animated: true, completion: presentCompletion)
  }
  
  
  func dismissppUp(){
    currentView?.dismiss(animated: true)
  }

  private func removeBackGesture() {
    if let navVC = currentView?.navigationController,
      let gesture = navVC.interactivePopGestureRecognizer {
      navVC.navigationBar.removeGestureRecognizer(gesture)
    }
  }

  private  func addCustomBottomLine(color: UIColor, height: Double) {
    navigationBar.setValue(true, forKey: "hidesShadow")
    let lineView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: height))
    lineView.backgroundColor = color
    navigationBar.addSubview(lineView)
    lineView.translatesAutoresizingMaskIntoConstraints = false
    lineView.widthAnchor.constraint(equalTo: navigationBar.widthAnchor).isActive = true
    lineView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    lineView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
    lineView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
  }


  private func configure() {

  }

}

