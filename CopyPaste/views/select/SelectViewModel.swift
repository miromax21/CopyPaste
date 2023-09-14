//
//  SelectUserViewModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 17.10.2022.
//

import UIKit

class SelectViewModeConfiguration {
  enum Metrics: String {
    case topView, bottomView, listMin
  }
  enum SubviewType {
    case defaultForPlacement(String), someView(UIView)
  }
  var topView: SubviewType?
  var bottomView: SubviewType?
  var collectionView: (UIDataSourceTranslating & UIView)!
  var vertivalMetrics: [Metrics: Int]!
  var horizontallMetrics: [Metrics: String] = [:]
  var scrollForHide: CGFloat = 100
  init(
    horizontallMetrics: [Metrics: String]? = nil,
    vertivalMetrics: [Metrics: Int]? = nil,
    initComplete: ((_: UIDataSourceTranslating) -> Void)? = nil
  ) {
    self.horizontallMetrics = horizontallMetrics ?? [:]
    self.vertivalMetrics = vertivalMetrics ?? [.topView: 60, .bottomView: 60, .listMin: 400]
    self.initComplete = initComplete
  }
  func setCollection(layout: UICollectionViewLayout? = nil){
    let listView = ListView(layout: layout, frame: .zero)
    listView.clipsToBounds = true
    collectionView = listView
  }
  
  func setList(layout: UICollectionViewLayout? = nil){
    let listView = UITableView()
    listView.clipsToBounds = true
    collectionView = listView
  }
  
  var initComplete: ((_: UIDataSourceTranslating) -> Void)?
  var emit: ((Any?) -> Void)?

  var selectedItem: IndexPath? {
    didSet {
      emit?(nil)
    }
  }
}

final class SelectViewModel: BaseViewModel {
  var configuration: SelectViewModeConfiguration!
  init(coordinator: BaseCoordinator, configuration: SelectViewModeConfiguration) {
    super.init(coordinator: coordinator)
    self.configuration = configuration
  }
}

