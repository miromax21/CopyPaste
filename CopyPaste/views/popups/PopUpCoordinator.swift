//
//  PopUpCoordinator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
enum PresentSize: Int {
  case full = 95, large = 70, middle = 50, doubleMin2 = 40, doubleMin = 30, min = 15, min2 = 20
  var size: Int {
    return self.rawValue
  }
}
class PopUpCoordinator: BaseCoordinator {
  enum AppPresentableCoordinatorEnum {
    case qrCode
  }

  func getPopup(next: AppPresentableCoordinatorEnum) -> /*PresentableViewController*/CustomPresentable {
    switch next {
    case .qrCode: return qrCode()
    }
  }

  private func qrCode() -> /*PresentableViewController*/ CustomPresentable {
    let viewModel = CameraViewModel(coordinator: self)
    let view = CamereViewController()
    view.viewModel = viewModel
    return view
  }
}
