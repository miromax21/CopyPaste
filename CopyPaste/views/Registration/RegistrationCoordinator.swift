//
//  RegistrationCoordinator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import Foundation
import UIKit
final class RegistrationCoordinator: BaseCoordinator {
  var reRegistration = false
  override init() {
    super.init()
    reRegistration = false
  }

  override func start() {
    showRegistration()
    appCoordinator.navigationController.navigationBar.isHidden = true
  }

  func showRegistration() {
    let viewModel = LoginViewModel(coordinator: self)
    let view = LoginViewController()
    view.viewModel = viewModel
    viewModel.reRegistration = reRegistration
    appCoordinator.navigationController.start(with: view, animate: false)
  }

  func showCamera(completion: ((_ callBack: Any?) -> Void)? = nil) {
    appCoordinator.navigationController.present(
      PopUpCoordinator().getPopup(next: .qrCode),
      completion: completion
    )
  }
}
