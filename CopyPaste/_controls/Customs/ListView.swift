//
//  TopCollectionViewBar.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 06.04.2023.
//

import UIKit
typealias ListView = UICollectionView
extension ListView {
  convenience init(layout: UICollectionViewLayout? = nil, frame: CGRect? = nil) {
    self.init(
      frame: frame ?? .zero,
      collectionViewLayout: layout ?? UICollectionViewFlowLayout()
    )
    self.showsHorizontalScrollIndicator = false
    self.showsVerticalScrollIndicator = false
    self.backgroundColor = AppColors.backgroundMain.color
  }

  func registertSubViews(
    cells: UICollectionReusableView.Type...,
    subviews: (String, UICollectionReusableView.Type)...
  ) {
    cells.forEach {
      self.register($0.self, forCellWithReuseIdentifier: $0.identifier)
    }
    subviews.forEach {
      self.register($0.1.self, forSupplementaryViewOfKind: $0.0, withReuseIdentifier: $0.1.identifier)
    }
  }

  func update(source: UICollectionViewDataSource? = nil, layout: UICollectionViewLayout? = nil) {
    update(source: source)
    update(layout: layout)
  }

  func update(source: UICollectionViewDataSource? = nil) {
    if let source = source {
      self.dataSource = source
    }
    reloadData()
  }
  func update(layout: UICollectionViewLayout? = nil) {
    if let layout = layout {
      collectionViewLayout = layout
    }
    collectionViewLayout.collectionView?.setNeedsLayout()
  }
}
