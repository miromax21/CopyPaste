//
//  AppCoordinator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import UIKit
final class AppCoordinator {

  private(set) var navigationController: AppNavigationController!
  private(set) var coordinatorKey: AppCoordinatorEnum!
  var app: App!
  var initialCoordinator: AppCoordinatorEnum = .main(present: nil)
  
  init(navigationController: AppNavigationController) {
    self.navigationController = AppNavigationController()
  }
  func configure() {
 //   start(with: initialCoordinator, animate: false)
  }

  func next(coordinator: AppCoordinatorEnum, animate: Bool = true) {
    getCoordinator(coordinator: coordinator).start()
  }
  func start(with coordinator: AppCoordinatorEnum) {
    getCoordinator(coordinator: coordinator).start()
  }

  func start(with coordinator: BaseCoordinator, animate: Bool = true) {
    prepare(coordinator: coordinator)
    coordinator.start()
  }

  
  func setTheme(style: UIUserInterfaceStyle){
    navigationController.viewControllers.forEach{
      $0.overrideUserInterfaceStyle = style
    }
  }

  func logOut() {
    coordinatorKey = nil
    app.needAuthorization = true
  }

  fileprivate func getCoordinator(coordinator: AppCoordinatorEnum) -> BaseCoordinator {
    coordinatorKey = coordinator
    let nextCoordinator = coordinator.next
    prepare(coordinator: nextCoordinator)
    return nextCoordinator
  }

  private func prepare(coordinator: BaseCoordinator) {
    coordinator.appCoordinator = self
    coordinator.appCoordinator.navigationController = navigationController
  }
}
