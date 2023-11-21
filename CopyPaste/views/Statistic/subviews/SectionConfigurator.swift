//
//  Layouts.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 06.10.2022.
//

import UIKit

final class SectionConfigurator: NSObject, ModernSectionLayout {

  var dataSource: UICollectionViewDiffableDataSource<String, Sections>?

  typealias Key = String
  typealias Sections = CalendarSectionConfigurator.SectionLayoutEnum

  var onClick: ((IndexPath, Any?) -> Void)?
  var sectionKeys: [Key?] = []
  var layouts: [Key : ((_ envir: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection)] = [:]
  init(_ sections: [Key: Sections]) {
    super.init()
    sectionKeys = sections.map { $0.key }
    configure(sections)
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 50
    (layout as? UICollectionViewCompositionalLayout)?.configuration = config
  }

  func mapReusableView (
    _ kind: String,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath,
    header: HeaderItem?
  ) -> UICollectionReusableView? {
    switch kind {
    case "header":
        return buildItem(model: header, collectionView, forIndexPath, kind) as HeaderSupplementaryView<Any>?
    default:
      assertionFailure("Unexpected element kind: \(kind).")
      return UICollectionReusableView()
    }
  }
}

// MARK: - - extension  ModernSectionLayout -
extension SectionConfigurator {

  func configureDatasource(collectionView: UICollectionView) {

    dataSource = UICollectionViewDiffableDataSource<String, Sections>(
      collectionView: collectionView,
      cellProvider: { [unowned self] collectionView, indexPath, item in
        var cell: UICollectionViewCell?
        switch item {
          case .tvSet:
            cell = buildItem(model: nil, collectionView, indexPath) as MonthCell?
        default: break
        }

        return cell
      }
    )
    dataSource?.supplementaryViewProvider = { [unowned self] (collectionView, kind, indexPath) in
      return self.mapReusableView(
        kind, collectionView, indexPath, header: HeaderItem(name: self.sectionKeys[indexPath.row])
      )
    }
    configureDatasource(collectionView: collectionView, datasource: dataSource)
  }

  func apply(snapshot: Snapshot, animate: Bool = false) {
    dataSource?.apply(snapshot, animatingDifferences: animate)
  }
}

extension SectionConfigurator: SectionLayout {
  func mapCell(_ model: Any?, _ collectionView: UICollectionView, _ forIndexPath: IndexPath, layoutIndex: Int?) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
  func mapCell<T: ConfigureCellProtocol>(
    _ model: T.CellModel,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath,
    layoutIndex: Int?
  ) -> T? {
    let cell: T? = buildItem(model: model, collectionView, forIndexPath)
    return cell
  }
}
