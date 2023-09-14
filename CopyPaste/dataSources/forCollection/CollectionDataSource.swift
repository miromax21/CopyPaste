//
//  CollectionDataSource.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 23.09.2022.
//

import UIKit
protocol Updated{
  var updateCollection: (() -> Void)? {get set}
}

final class CollectionDataSource<T>: NSObject, Updated, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  var updateCollection: (() -> Void)?
  var minHeaderSize: CGFloat = 50.0

  var sectionss: [SectionModel<T>] = []
  var config: (any SectionLayout)! {
    didSet {
      setUpSections()
    }
  }
  var isEmpty: Bool {
    return initialItems.count == 0 && sectionss.reduce(0){$0 + ($1.items?.count ?? 0)} == 0
  }
  private var initialItems: [CollectionModel<T, String>] = []
  
  init(items: [CollectionModel<T, String>]) {
    super.init()
    initialItems = items
  }
  convenience init(items: [CollectionModel<T, String>], config: any SectionLayout) {
    self.init(items: items)
    self.config = config
  }
  
  init(sections: [SectionModel<T>]){
    super.init()
    sections.enumerated().forEach {
      sectionss.append($0.element)
      sectionss[$0.offset].layoutIndex = $0.offset
    }
  }
  convenience init(sections: [SectionModel<T>], config: any SectionLayout) {
    self.init(sections: sections)
    self.config = config
  }
  
  func update(for indexPath: IndexPath, with item: T){
    sectionss[indexPath.section].items?[indexPath.row] = item
  }

  typealias CellProvider = (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ model: SectionModel<T>) -> UICollectionViewCell?
  var provider: CellProvider?
  convenience init(
    sections: [SectionModel<T>],
    config: any SectionLayout,
    _ provider: CellProvider?)
  {
    self.init(sections: sections, config: config)
    self.provider = provider
  }

  func addSection(section: SectionModel<T>) {
    self.sectionss.append(section)
  }

  func setUpSections() {
    sectionss = config?.mapSection(models: initialItems) as! [SectionModel<T>]
  }
  
  func setSection(_ section: SectionModel<T>) {
    let index = section.layoutIndex
    if index >= 0 && sectionss.count - 1 <= index {
      sectionss[index] = section
    } else {
      sectionss.insert(section, at: index)
    }
  }

// MARK: -  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sectionss.count
  }
  

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    sectionss[section].items?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = sectionss[indexPath.section]
    if let cell = provider?(collectionView, indexPath, section) {
      return cell
    }
//    if let model = section.items?[indexPath.row] as? TVCollectionCell.CellModel,
//      let cell = config.mapCell(model, collectionView, indexPath, layoutIndex: section.layoutIndex) as? TVCollectionCell {
//      return cell
//    }
    return UICollectionViewCell()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    let view = config.mapReusableView(kind, collectionView, indexPath, header: sectionss[indexPath.section].header)
    return view ?? UICollectionReusableView()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    UIView.animate(withDuration: 1, animations: {
      let frame = cell.frame
      cell.frame = CGRect(x: frame.origin.x + 50, y: frame.origin.y, width: frame.width, height: frame.height)
    })
  }
  
  
}
