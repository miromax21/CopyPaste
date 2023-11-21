import UIKit

import Foundation

protocol Coordinator {
  func start()
  func cancel()
}

class BaseCoordinator: NSObject, Coordinator {
  var type: AppCoordinatorEnum!
  weak var appCoordinator: AppCoordinator!
  weak var app: App? {
    return appCoordinator?.app
  }

  weak var currentPopUp: UIViewController? {
    return appCoordinator.navigationController.currentView
  }
  func start() {}
  func cancel() {}
}

final class PresentableCoordinator: BaseCoordinator {
  var view: (any CustomPresentable)!
}


protocol BaseVM {
  var coordinator: BaseCoordinator! { get }
}

class BaseViewModel: BaseVM {
  var coordinator: BaseCoordinator!
  init(coordinator: BaseCoordinator) {
    self.coordinator = coordinator
  }
}
