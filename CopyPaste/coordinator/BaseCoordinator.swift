//
//  BaseCoordinator.swift
//  CopyPaste
//
//  Created by Sergey Zhidkov on 06.12.2022.
//

import UIKit

protocol Coordinator: AnyObject {
  func start()
}

class BaseCoordinator: Coordinator {
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
enum AppCoordinatorEnum {
  case registration
  case main(present: UIViewController?)

  var value: String? {
    return String(describing: self).components(separatedBy: "(").first
  }
  var next: BaseCoordinator {
    return BaseCoordinator()
  }

  var animationDirection: CATransitionSubtype? {
    switch self {
    default:    return nil
    }
  }
  var showNavBar: Bool {
    switch self {
    case .registration: return false
    default:    return true
    }
  }
}
