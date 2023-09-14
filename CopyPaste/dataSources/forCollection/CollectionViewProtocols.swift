//
//  CollectionViewProtocols.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 22.02.2023.
//

import UIKit
protocol SectionLayoutProtocol: Hashable {
  var layoutSection: ((_ environ: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection) {get}
}

// MARK: SectionProtocol
protocol SectionProtocol: AnyObject {
  associatedtype Key: Hashable
  associatedtype Sections: SectionLayoutProtocol

  associatedtype Datasource: UICollectionViewDataSource
  var dataSource: Datasource? {get set}
  var layout: UICollectionViewLayout {get}
  var onClick: ((IndexPath, Any?) -> Void)? { get set}
  var sectionKeys: [Key?] { get set}

  func mapReusableView (_ kind: String,
                        _ collectionView: UICollectionView,
                        _ forIndexPath: IndexPath,
                        header: HeaderItem?) -> UICollectionReusableView?
}

extension SectionProtocol {
  func buildItem<T: ConfigureCellProtocol>(
    model: T.CellModel?,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath,
    _ kind: String? = nil,
    config: [String: Any]? = nil
  ) -> T? {
    var view: T?
    view = (kind != nil
            ? collectionView.dequeueReusableSupplementaryView(
              ofKind: kind!,
              withReuseIdentifier: T.identifier,
              for: forIndexPath
            )
            : collectionView.dequeueReusableCell(withReuseIdentifier: T.identifier, for: forIndexPath)) as? T
    view?.configure(viewModel: model, config: config)
    return view
  }

  func mapSection<T>(models: [T]?) -> [SectionModel<T>]? {
    return [SectionModel<T>(items: models, header: HeaderItem(name: "", onClick: onClick))]
  }

  func configureDatasource(collectionView: UICollectionView, datasource: Datasource?) {
    dataSource = datasource
    collectionView.dataSource = datasource
  }
}

// MARK: ModernSectionLayout
protocol ConfigureDatasource {
  func configureDatasource(collectionView: UICollectionView)
}
protocol ModernSectionLayout: ConfigureDatasource,
                              SectionProtocol where Datasource == UICollectionViewDiffableDataSource<String, Sections> {
  typealias Snapshot = NSDiffableDataSourceSnapshot<String, Sections>
  var layouts: [Key: ((_ environ: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection)] {get set}
}

extension ModernSectionLayout {

  var layout: UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environ) -> NSCollectionLayoutSection? in
      return self?.createLayoutSections(for: sectionIndex, environ: environ)
    }
  }

  func setLayoutConfiguration( _ configuration: UICollectionViewCompositionalLayoutConfiguration? = nil) {
    if let compositionalLayout = layout as? UICollectionViewCompositionalLayout, let configuration = configuration {
      compositionalLayout.configuration = configuration
    }
  }

  func configure(_ sections: [Key: Sections]) {
    sectionKeys = sections.map { $0.key }
    sections.forEach {
      self[$0.key] = $0.value.layoutSection
    }
  }

  func createLayoutSections(for sectionIndex: Int, environ: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
    guard let key = sectionKeys[sectionIndex],
          let function = self[key]
    else { return nil }
    return function(environ)
  }

  subscript(sectionKey: Key) -> ((_ :NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection)? {
    get { return layouts[sectionKey] }
    set { layouts[sectionKey] = newValue }
  }

  func getItem(for indexPath: IndexPath) -> Sections? {
    return dataSource?.itemIdentifier(for: indexPath)
  }

  func apply(snapshot: Any, animate: Bool = false) {
    if let snapshot = snapshot as? NSDiffableDataSourceSnapshot<String, Self.Sections> {
      dataSource?.apply(snapshot, animatingDifferences: animate)
    }
  }
}

protocol SectionLayout: SectionProtocol {
  func mapCell(
    _ model: Any?,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath, layoutIndex: Int?
  ) -> UICollectionViewCell

  func mapCell2<T: ConfigureCellProtocol>(
    _ model: T.CellModel,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath,
    layoutIndex: Int?
  ) -> T?
}
// delete
extension SectionLayout {

  func mapCell2<T: ConfigureCellProtocol>(
    _ model: T.CellModel,
    _ collectionView: UICollectionView,
    _ forIndexPath: IndexPath,
    layoutIndex: Int?
  ) -> T? { return nil }
}
