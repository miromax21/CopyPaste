//
//  AppCoordinator.swift
//  CopyPaste
//
//  Created by Sergey Zhidkov on 06.12.2022.
//

import UIKit

final class AppCoordinator {

  var navigationController: AppNavigationController!
  var coordinatorKey: AppCoordinatorEnum!

  var initialCoordinator: BaseCoordinator {
    let coordinator: AppCoordinatorEnum = true ? .registration : .main(present: nil)
    return getCoordinator(coordinator: coordinator)
  }

  init(navigationController: AppNavigationController) {
    self.navigationController = AppNavigationController()
    initialCoordinator.appCoordinator = self
    initialCoordinator.appNavigationController = navigationController
    start(with: initialCoordinator, animate: false)
  }

  func next(coordinator: AppCoordinatorEnum, animate: Bool = true) {
    getCoordinator(coordinator: coordinator).start()
  }

  func start(with coordinator: BaseCoordinator, animate: Bool = true) {
    prepare(coordinator: coordinator)
    coordinator.start()
  }

  func start(relativByMain view: [UIViewController]) {

    guard String(describing: view.self) != String(describing: navigationController.currentView.self) else {
      return
    }
//    if navigationController.mainScreen == nil {
//      (initialCoordinator as? MainCoordinator)?.start()
//    }
    var views = view
    views.insert(navigationController.mainScreen!, at: 0)
    navigationController.start(with: views, animate: false)
  }

  fileprivate func getCoordinator(coordinator: AppCoordinatorEnum) -> BaseCoordinator {
    coordinatorKey = coordinator
    let nextCoordinator = coordinator.next
    navigationController.navigationBar.isHidden = !coordinator.showNavBar
    prepare(coordinator: nextCoordinator)
    return nextCoordinator
  }

  private func prepare(coordinator: BaseCoordinator) {
    coordinator.appCoordinator = self
    coordinator.appNavigationController = navigationController
  }
}
