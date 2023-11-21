//
//  PopUpCoordinator.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit
enum PresentSize: Int {
  case full = 95, large = 70, middle = 50, doubleMin2 = 40, doubleMin = 30, min = 15, min2 = 20
  var size: Int {
    return self.rawValue
  }
}
final class PopUpCoordinator: BaseCoordinator {
  enum AppPresentableCoordinatorEnum {
    case qrCode
    case selectedView(configuration: SelectViewModeConfiguration)
    case selectedDiffableView(configuration: SelectViewModeConfiguration)
    case some(view: any CustomPresentable)
  }

  func getPopup(next: AppPresentableCoordinatorEnum) -> any CustomPresentable {
    switch next {
    case .qrCode: return qrCode()
    case .selectedView(let configuration):
      return selectView(configuration: configuration)
    case .selectedDiffableView(let configuration):
      return selectedDiffableView(configuration: configuration)
    case .some(let view): return view
    }
  }

  private func qrCode() -> any CustomPresentable {
    let viewModel = CameraViewModel(coordinator: self)
    let view = CamereViewController()
    view.viewModel = viewModel
    return view
  }

  func selectedDiffableView(configuration: SelectViewModeConfiguration) -> any CustomPresentable {
    let viewModel = SelectViewModel(coordinator: self, configuration: configuration)
    let view = SelectViewController()
    view.viewModel = viewModel
    return view
  }

  func selectView(configuration: SelectViewModeConfiguration) -> any  CustomPresentable {
    let viewModel = SelectViewModel(coordinator: self, configuration: configuration)
    let view = SelectViewController()
    view.viewModel = viewModel
    return view
  }

}
