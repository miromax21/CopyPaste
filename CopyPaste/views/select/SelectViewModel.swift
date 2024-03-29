//
//  SelectUserViewModel.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 17.10.2022.
//

import UIKit
import Combine
// MARK: SelectViewModeConfiguration -
final class SelectViewModeConfiguration {
  enum Metrics: String {
    case topView, bottomView, listView
  }
  enum SubviewType {
    case defaultForPlacement(String?, ControllSettings?), someView(UIView), emptySpace(Int)
  }
  var topMargin: Int = 15
  var topView: SubviewType?
  var bottomView: SubviewType?
  var collectionView: (UIDataSourceTranslating & UIView)!
  var vertivalMetrics: [Metrics: Int]!
  var horizontallMetrics: [Metrics: String] = [:]
  var scrollForHide: CGFloat = 100
  var initComplete: ((_: UIDataSourceTranslating) -> Void)?
  var emit: ((Any?) -> Void)?

  var selectedItem: IndexPath? {
    didSet {
      emit?(nil)
    }
  }

  var mapper: ((
    _ items: [SelecTableViewCell.SelecTableViewCellModel],
    _ collection: (UIDataSourceTranslating & UIView)
  ) -> Void)?

  init(
    horizontallMetrics: [Metrics: String]? = nil,
    vertivalMetrics: [Metrics: Int]? = nil,
    initComplete: ((_: UIDataSourceTranslating) -> Void)? = nil
  ) {
    self.horizontallMetrics = horizontallMetrics ?? [:]
    self.vertivalMetrics = vertivalMetrics ?? [.topView: 60, .bottomView: 60, .listView: 400]
    self.initComplete = initComplete
  }

  func setCollection(layout: UICollectionViewLayout? = nil) {
    let listView = ListView(layout: layout, frame: .zero)
    listView.clipsToBounds = true
    collectionView = listView
  }

  func setList(config: ControllSettings? = nil) {
    let listView = UITableView()
    listView.clipsToBounds = true
    collectionView = listView
  }
}

// MARK: - SelectViewModel -
final class SelectViewModel: BaseViewModel {
  var configuration: SelectViewModeConfiguration!
  var items: [SelecTableViewCell.SelecTableViewCellModel]? {
    didSet {
      if let items = items {
        configuration.mapper?(items, configuration.collectionView)
      }
    }
  }
  init(coordinator: BaseCoordinator, configuration: SelectViewModeConfiguration) {
    super.init(coordinator: coordinator)
    self.configuration = configuration
  }
}
