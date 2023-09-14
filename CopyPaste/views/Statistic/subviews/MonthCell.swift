//
//  MonthCell.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 17.02.2023.
//

import UIKit
final class MonthCell: UICollectionViewCell, ConfigureCellProtocol {
  var emit: ((String?) -> Void)?
  typealias CellModel = String

  var config: [String: Any]?

  var viewModel: String? {
    didSet {
      month.text = viewModel ?? ""
    }
  }
  func configure(viewModel: String?, config: [String: Any]?) {
    self.viewModel = viewModel
  }

  var month: UILabel = {
    return UILabel()
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.customInit()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.customInit()
  }

  private func customInit() {
    addSubview(month)
    addConstraintsWithFormat("H:|[v0]|", views: month)
    addConstraintsWithFormat("V:|[v0]|", views: month)
    month.textAlignment = .center
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    emit?(viewModel)
    self.isSelected = true
  }

  override var isSelected: Bool {
      didSet {
        backgroundColor = isSelected ? UIColor.gray : UIColor.clear
      }
  }
}
