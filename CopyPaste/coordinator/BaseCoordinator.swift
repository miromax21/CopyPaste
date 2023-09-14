import UIKit

import Foundation

protocol Coordinator {
  func start()
}

class BaseCoordinator: NSObject, Coordinator {
  var type: AppCoordinatorEnum!
  unowned var appCoordinator: AppCoordinator!
  unowned var appNavigationController: AppNavigationController!
  convenience init(appNavigationController: AppNavigationController) {
    self.init()
    self.appNavigationController = appNavigationController
  }
  func start() {}
}

class PresentableCoordinator: BaseCoordinator {
  var view: PresentableViewController!
}

class BaseViewModel {
  var coordinator: BaseCoordinator!
  init(coordinator: BaseCoordinator) {
    self.coordinator = coordinator
  }
}
