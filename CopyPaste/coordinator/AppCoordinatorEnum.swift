//
//  AppCoordinatorEnum.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import UIKit
enum AppCoordinatorEnum {
  case main(present: UIViewController?)
  case auth

  var value: String? {
    return String(describing: self).components(separatedBy: "(").first
  }
  var next: BaseCoordinator {
    var next: BaseCoordinator!
    switch self {
    case .main(let present): next = TabBarCoordinator(showWithBlure: present)
    case .auth:next = RegistrationCoordinator()
    }
    return next
  }

  var animationDirection: CATransitionSubtype? {
    switch self {
    default:    return nil
    }
  }
  var showNavBar: Bool {
    switch self {
    case .auth: return false
    default:    return false
    }
  }
}
