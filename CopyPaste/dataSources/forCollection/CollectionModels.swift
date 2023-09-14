//
//  CollectionModels.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import UIKit
protocol IdentifyModel {
  var id: UUID { get set }
}

final class CollectionModel<T, PID: Hashable> {
  var item: T
  var parentId: PID
  init(item: T, parentId: PID) {
    self.item = item
    self.parentId = parentId
  }
}


protocol WithMode: UICollectionReusableView {
  associatedtype ModeType
  var modeType: ModeType? {get set}
}

protocol ConfigureCellProtocol: UICollectionReusableView {
  associatedtype CellModel
  var emit: ((CellModel?) -> Void)? { get  }
  var viewModel: CellModel? { get set }
  func configure(viewModel: CellModel?, config: [String: Any]?)
}
extension ConfigureCellProtocol {
  var modelKey: String {
      return "model"
  }
  var emit: ((CellModel?) -> Void)? {
    return nil
  }
}
//extension WithMode {
//  var shakeAnimationPath: String {
//    return "transform"
//  }
//
//  func makeShake(param: Int) {
//    let transformAnim = CAKeyframeAnimation(keyPath: shakeAnimationPath)
//    transformAnim.values = [
//      NSValue(caTransform3D: CATransform3DMakeRotation(0.02, 0.0, 0.0, 1.0)),
//      NSValue(caTransform3D: CATransform3DMakeRotation(-0.02, 0, 0, 1))
//    ]
//    transformAnim.autoreverses = true
//    transformAnim.duration = (param % 2) == 0 ? 0.115 : 0.105
//    transformAnim.repeatCount = Float.infinity
//    self.layer.add(transformAnim, forKey: shakeAnimationPath)
//  }
//}

protocol ConfigureHeaderCellProtocol: UICollectionReusableView {
  associatedtype CellModel: Identifiable
  associatedtype ParentId: Hashable
  // swiftlint:disable:next type_name
  associatedtype M: CollectionModel<CellModel, ParentId>
  var viewModel: Section<M>.Item? { get set }
}
struct HeaderItemControls {
  var control: UIView?
  var click: (([String: Any?]) -> Void)?
}
struct HeaderItem {
  var name: String?
  var controlsView: UIView?
  var onClick: ((IndexPath, Any) -> Void)?
}

struct Section<M> {
  struct Item {
    var value: M?
    var type: String = ""
  }

  var header: HeaderItem
  var items: [Item]
}

struct Item<T> {
  var value: T
  var type: String = ""
}

protocol SectionModelProtocol<T> {
  // swiftlint:disable:next type_name
  associatedtype T
  var cell: UICollectionViewCell.Type? { get set }
  var header: HeaderItem? { get set }
  var items: T { get set }
}

final class SectionModel<Model>: SectionModelProtocol {
  var items: [Model]? = nil  //[Model] = []
  var cell: UICollectionViewCell.Type?
  var layoutIndex: Int = 0
  var header: HeaderItem?


  init(items: [Model]?, header: HeaderItem? = nil, at: Int = 0) {
    self.items = items
    self.header = header
    layoutIndex = at
  }
}

protocol ConfigureCellProtocol2: UICollectionViewCell {
  associatedtype Model
  var click: ((Model?) -> Void)? { get set }
  var id: String? { get set }
  var viewModel: Model? { get set }
}

