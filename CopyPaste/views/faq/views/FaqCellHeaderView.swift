//
//  FaqCellView.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 06.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import UIKit

class FaqCellHeaderView: UIView, ConfigureHeaderViewProtocol {

  typealias Model = String

  @IBOutlet var contentView: UIView!
  @IBOutlet weak var indexLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  func configure(_ title: String?, param: [String: Any]?) {
    if param?["section"] == nil {
      indexLabel.alpha = 0
    }
    if let isfloatCell = param?["isfloatCell"] as? Bool {
      if isfloatCell {
        indexLabel.alpha = 0
        titleLabel.alpha = 0
        self.contentView.backgroundColor = AppColors.backgroundMain.color
      }
    }
    indexLabel?.text = "\(String(describing: param?["section"]))"
    titleLabel?.text = title?.uppercased()
  }

  func commonInit() {
    Bundle.main.loadNibNamed("FaqCellHeaderView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    indexLabel.layer.cornerRadius = indexLabel.bounds.height / 2

    indexLabel.textColor = .white
    titleLabel.textColor = .black
    indexLabel.backgroundColor = .gray
//    contentView.backgroundColor = AppColors.listCells.color(alpha: 50)
  }

  func configure(section: Int, title: String) {
    indexLabel?.text = "\(section + 1)"
    titleLabel?.text = title.uppercased()
  }
}
