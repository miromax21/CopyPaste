//
//  TabbBarCoordinator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 11.10.2022.
//

import Foundation
import UIKit
class TabBarCoordinator: BaseCoordinator {

  var showWithBlure: UIViewController?
  var tabBarController: UITabBarController!
  weak var currentView: UIViewController?
  lazy var main: UIViewController = {
    var main = TabBarCoordinator(appNavigationController: appNavigationController)
    main.start()
    main.appNavigationController = appNavigationController
    return main.appNavigationController.currentView!
  }()

  convenience init(showWithBlure: UIViewController? = nil) {
    self.init()
    self.showWithBlure = showWithBlure
    tabBarController = UITabBarController()
//    tabBarController.delegate = self //UIApplication.shared.delegate as? UITabBarControllerDelegate
  }

  override func start() {
    tabBarController.view.backgroundColor = AppColors.backgroundMain.color
    tabBarController.setViewControllers([
      createNavController(for: showFaq(), image: IconEnum.home.icon),
    ], animated: false)
    appCoordinator.navigationController.start(with: tabBarController)
    if let showWithBlure = showWithBlure {
      appCoordinator.navigationController.present(showWithBlure)
    }
    self.tabBarController.title = ""
  }

  fileprivate func createNavController(for rootViewController: UIViewController,
                                       title: String? = nil,
                                       image: UIImage? = nil) -> UIViewController {
    let item = UITabBarItem(title: title, image: image, tag: 0)
    item.imageInsets = UIEdgeInsets.init(top: 15, left: 0, bottom: -15, right: 0)
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem = item
    return navController
  }

//  func showStatistic() -> UIViewController {
//    let viewModel = StatisticViewModel(coordinator: self)
//    let view = StatisticViewController()
//    view.viewModel = viewModel
//    return view
//  }

  func showFaq() -> UIViewController {
    let viewModel = FaqViewModel(coordinator: self)
    return viewModel.start()
  }
}
