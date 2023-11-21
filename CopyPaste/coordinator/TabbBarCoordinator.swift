//
//  TabbBarCoordinator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 11.10.2022.
//

import Foundation
import UIKit
final class TabBarCoordinator: BaseCoordinator, UITabBarControllerDelegate {
  var showWithBlure: UIViewController?
  var tabBarController: UITabBarController!
  var names: [String?] = []
  convenience init(showWithBlure: UIViewController? = nil) {
    self.init()
    names = [nil, "Loc(Loc.Global.notifications)", "Loc(Loc.Global.settings)"]
    self.showWithBlure = showWithBlure
    tabBarController = UITabBarController()
    tabBarController.tabBar.unselectedItemTintColor = AppColors.inactiveText.color
    UITabBar.appearance().tintColor = AppColors.backgroundMainReverse.color
    tabBarController.tabBar.backgroundColor = AppColors.lightGray.color
    tabBarController.delegate = self
  }

  override func start() {
    tabBarController.view.backgroundColor = AppColors.backgroundMain.color
    tabBarController.setViewControllers([
      createNavController(for: showFaq(), image: IconEnum.home.icon),
//      createNavController(for: showNotifications(), image: IconEnum.notification.icon),
//      createNavController(for: showSettings(), image: IconEnum.settings.icon)
    ], animated: false)
    appCoordinator.navigationController.start(with: tabBarController)
    if let showWithBlure = showWithBlure {
      appCoordinator.navigationController.present(showWithBlure)
    }
    self.tabBarController.title = ""
  }
  override func cancel() {
    super.cancel()
    tabBarController = nil
    appCoordinator = nil
  }

  func push(view: UIViewController) {
    if let navigation = tabBarController.navigationController {
      navigation.navigationBar.isHidden = false
      navigation.pushViewController(view, animated: true)
    }
  }
  
  func showFaq() -> UIViewController {
    let viewModel = FaqViewModel(coordinator: self)
    return viewModel.start()
  }

  func showPopUp(_ popUp: PopUpCoordinator.AppPresentableCoordinatorEnum,
                 completion:  ((_ callBack: CustomPresentableCopletion) -> Void)? = nil,
                 presentSize: PresentSize = .full
  ) {
    appCoordinator.navigationController.present(
      PopUpCoordinator().getPopup(next: popUp),
      completion: completion
    )
  }

  fileprivate func createNavController(for rootViewController: UIViewController,
                                       title: String? = nil,
                                       image: UIImage? = nil) -> UIViewController {
    let item = UITabBarItem(title: title, image: image, tag: 0)
    let tabBarHeight = tabBarController.tabBar.frame.height
    let imageHeight = item.image?.size.height ?? 0
     //
    let window = UIApplication.shared.windows.first
    var inset = window?.safeAreaInsets.bottom ?? 0.0
    inset = CGFloat(Int((tabBarHeight - imageHeight + inset) / 2)) / 2
    item.imageInsets = UIEdgeInsets(top: inset,
                                    left: 0,
                                    bottom: -inset,
                                    right: 0)
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem = item
    return navController
  }

}
