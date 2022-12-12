//
//  AppNavigationController.swift
//  CopyPaste
//
//  Created by Sergey Zhidkov on 06.12.2022.
//

import UIKit
protocol ShowAlert {
  func showAlert(alertVC: UIAlertController)
  func showAlert(alert: AlertService.AlertType, options: ToatOptions?)
  func updateUi(next: UpdateUiEnum)
  func next(viewController: UIViewController, animate: Bool)
}

enum UpdateUiEnum {}
protocol UpdateUI {
  func updateUI(next: UpdateUiEnum)
}
final class AppNavigationController: UINavigationController, ShowAlert {

  var presentedView: PresentableViewController?
  var mainScreen: UIViewController? {
    return viewControllers.first // (where: {$0 is UIViewController}) as? UIViewController
  }

  var currentView: UIViewController? {
    return viewControllers.last
  }

  lazy var transitionAnimation: CATransition = {
    let transition = CATransition()
    transition.duration = 0.3
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = .fade
    transition.subtype = .fromBottom
    return transition
  }()

  lazy var alertService: AlertService? = {
     return AlertService()
  }()

  override func popViewController(animated: Bool) -> UIViewController? {
    return pop(transition: nil)?.last
  }

  func addCustomBottomLine(color: UIColor, height: Double) {
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

  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
    return false
  }

  func start(with viewController: [UIViewController], animate: Bool = true) {
    viewControllers = viewController
    if animate {
      view.layer.add(transitionAnimation, forKey: nil)
    }
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

  func presentViewControllerModaly(vc: UIViewController, presentCompletion: (() -> Void)? = nil) {
    currentView?.present(vc, animated: true, completion: {
      presentCompletion?()
    })
  }

  func pop(transition: UIView.AnimationTransition? = .flipFromRight) -> [UIViewController]? {
    if let view = currentView as? DisposableViewController {
      view.removeReference()
    }
    view.layer.add(transitionAnimation, forKey: nil)
    return popToRootViewController(animated: false)
  }

  func updateUi(next: UpdateUiEnum) {
    guard DeviceUtilsService.shared.screenIsAvalable.value == true else { return }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {return}
      switch next {
      default: (self.currentView as? UpdateUI)?.updateUI(next: next)
      }
    }
  }

  func showAlert(alertVC: UIAlertController) {
    guard DeviceUtilsService.shared.screenIsAvalable.value else { return }
    let alert = alertVC
    if presentedView != nil {
      presentedView!.present(alert, animated: true)
      return
    }
    currentView?.present(alert, animated: true, completion: nil)
  }

  func showAlert(alert: AlertService.AlertType, options: ToatOptions? = nil) {
    guard DeviceUtilsService.shared.screenIsAvalable.value else { return }
    alertService?.next(alert: alert, options: options)
  }

  func present(
    _ view: PresentableViewController,
    completion: ((_ callBack: Any?) -> Void)? = nil,
    presentCompletion: (() -> Void)? = nil
  ) {
    presentedView = view
    presentedView?.complete = completion
    currentView?.present(view, animated: true, completion: presentCompletion)
  }

  func present(
    _ view: PresentableViewController,
    presentSize: PresentSize = .full,
    completion: ((_ callBack: Any?) -> Void)? = nil
  ) {
    if presentedView != nil && presentedView! == view {
      return
    }
    presentedView = view
    presentedView?.complete = { [weak self] callBack in
      self?.presentedView?.dismiss(animated: true, completion: {
        self?.presentedView = nil
        completion?(callBack)
      })
    }
    presentedView?.transitioningDelegate = currentView
    presentedView?.modalPresentationStyle = .custom
    presentedView?.presentSize = presentSize
    presentViewControllerModaly(vc: presentedView!)

  }

  func present(
    _ vc: UIViewController,
    style: UIModalPresentationStyle = .custom,
    presentCompletion: (() -> Void)? = nil
  ) {
    vc.transitioningDelegate = currentView
    vc.modalPresentationStyle = style
    currentView?.present(vc, animated: true, completion: presentCompletion)
  }

  private func removeBackGesture() {
    if let navVC = currentView?.navigationController,
      let gesture = navVC.interactivePopGestureRecognizer {
      navVC.navigationBar.removeGestureRecognizer(gesture)
    }
  }

  func configure() {
    navigationBar.topItem?.title = ""
    addCustomBottomLine(color: AppColors.alertInfo.color, height: 1.0)
    addCustomizedBackBtn()
    UINavigationBar.appearance().topItem?.title = ""

    UIBarButtonItem.appearance().tintColor = AppColors.alertInfo.color

    let attr: [NSAttributedString.Key: Any] = [
      .foregroundColor: AppColors.alertInfo.color,
      .font: FontsEnum.base.getFont(size: 22.0),
      .backgroundColor: UIColor.clear
    ]
    UINavigationBar.appearance().titleTextAttributes = attr

  }

  private func addCustomizedBackBtn() {
    navigationBar.backIndicatorImage =  IconTypeEnum.back.getIcon(width: 16.0, height: 16.0)
    navigationBar.backIndicatorTransitionMaskImage = IconTypeEnum.back.icon
    currentView?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    currentView?.navigationItem.backBarButtonItem = nil
  }
}
