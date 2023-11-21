//
//  SettingsCell.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 02.12.2022.
//

import Foundation
import UIKit
import Combine
final class SelecTableViewCell: UITableViewCell, ConfigureTableCell {
  struct SelecTableViewCellModel {
    var title: String
    var subModel: Any?
    var active: Bool = false
  }
  typealias M = SelecTableViewCellModel
  enum Config: String {
    case first, last
  }
  var needBorder: Bool = false {
    didSet {
      lineview.alpha = needBorder ? 1 : 0
    }
  }
  lazy var title: UILabel = {
    var label = UILabel()
    label.font = FontsEnum.custom(name: .base, style: .bold).getFont(size: 16)
    label.textColor = AppColors.text.color
    return label
  }()
  var id: String?
  var contentSubview = UIView()

  var showed: Bool?
  var vh: NSLayoutConstraint!
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setUpViews()

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var border: CAShapeLayer?

  func configure(model: Any, param: [String: Any]?) {
    if let model = model as? M {
      configure(model, param: param)
    }
  }
  func setParams(param: [String: Any]?){
    if let params = param as? [String: Bool] {
      contentView.layer.masksToBounds = true
      var masks: CACornerMask = []
      if params[Config.first.rawValue] ?? false {
        needBorder = false
        masks.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
      }
      if params[Config.last.rawValue] ?? false {
        masks.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
      }
      self.roundCorners(masks, radius: 5)
    }
  }

  func configure(_ model: M, param: [String: Any]?) {
    defaultContentSubView(model: model)
    setParams(param: param)
  }
  lazy var lineview: UIView = {
    var view = UIView()
    view.backgroundColor = AppColors.primary.color(alpha: 75)
    return view
  }()
}

extension SelecTableViewCell {

  private func setUpViews() {

    [lineview, title].forEach {
      contentView.addSubview($0)
      contentView.addConstraintsWithFormat("H:|-15-[v0]-15-|", views: $0)
    }

    NSLayoutConstraint.activate([
      lineview.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      lineview.heightAnchor.constraint(equalToConstant: 1),
      title.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    backgroundColor = AppColors.backgroundSubview.color
  }

  func defaultContentSubView(model: M) {
//    if let submodel = model.subModel as? Loc.Settings, let key = Loc.Settings(rawValue: submodel.rawValue) {
//      title.text = Loc(key)
//    } else {
      title.text = model.title
//    }
    title.sizeToFit()
    setNeedsLayout()
  }

  func setnotifications() -> UIView {
    let contentSubview = UIView()
    let switchControl = UISwitch()
  //  switchControl.isOn = ServiceStore.shared.notifications.isEnabled
    title.text = "Notifications"
    contentSubview.addSubview(switchControl)
    switchControl.centerYAnchor.constraint(equalTo: contentSubview.centerYAnchor).isActive = true
    switchControl.addTarget(self, action: #selector(schengenotofications), for: .valueChanged)
    return contentSubview
  }
  @objc func schengenotofications(sender: UISwitch) {
   // ServiceStore.shared.notifications.configure(withNotification: true)
  }

}
