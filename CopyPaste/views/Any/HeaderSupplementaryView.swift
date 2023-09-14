//
//  HeaderCell.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 23.09.2022.
//

import UIKit
enum ModeTypes {
  case edit
}
final class HeaderSupplementaryView<T>: UICollectionViewCell, ConfigureCellProtocol {
  var emit: ((HeaderItem?) -> Void)?
  var config: [String : Any]?
  
  typealias ModeType = ModeTypes

  private var edit: Bool = false

  lazy var pointsLabel: UITextField = {
    var field = UITextField()
    field.placeholder = "Добавить приставку"
    field.isUserInteractionEnabled = false
    let frame = field.frame
    field.leftView = UIView(frame: CGRect(x: frame.minX, y: frame.minY, width: 20.0, height: frame.height))
    field.leftViewMode = .always
    return field
  }()
  

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.customInit()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.customInit()
    layoutIfNeeded()
  }

  lazy var border: CAShapeLayer = {
    var border = CAShapeLayer()
    border.strokeColor = UIColor.black.cgColor
    border.lineDashPattern = [2, 2]
    border.frame = self.bounds
    border.fillColor = nil
    let copy = pointsLabel.frame
    let rect = CGRect(x: copy.origin.x + 5, y: copy.origin.y + 2.5, width: copy.width - 10, height: copy.height - 20)

    border.path = UIBezierPath(roundedRect: rect, cornerRadius: 5.0).cgPath
    border.cornerRadius = 5
    return border
  }()

  var viewModel: HeaderItem? {
    didSet {
      setValue()
      addUserView()
      setNeedsLayout()
    }
  }
  
  func configure(viewModel: HeaderItem?, config: [String : Any]?) {
    self.viewModel = viewModel
  }
  
  var viewSize: CGSize? = CGSize(width: 120, height: 20)

  func addUserView(){
    addSubview(pointsLabel)
    addConstraintsWithFormat("V:|-[v0]-|", options: [.alignAllFirstBaseline, .alignAllCenterX], views: pointsLabel)
    if let userView = viewModel?.controlsView {
      addSubview(userView)
      addConstraintsWithFormat("V:|-[v0]-|", options: [.alignAllFirstBaseline, .alignAllCenterX], views: userView)
      addConstraintsWithFormat("H:|-[v0]-[v1]-|", options: [ .alignAllCenterY], metrics: ["w": "\(viewSize?.width ?? 20)"], views: pointsLabel, userView)
    }else{
      addConstraintsWithFormat("H:|-[v0]-|", options: [ .alignAllCenterY], views: pointsLabel)
    }
  }

  func customInit() {
    pointsLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    pointsLabel.textColor = AppColors.black.color
  }

  func setValue() {

    pointsLabel.textAlignment = .left
    guard let viewModel = viewModel else {
      return
    }
    pointsLabel.text = viewModel.name

    var attributes: [NSAttributedString.Key: Any] = [
      .font: FontsEnum.base.getFont(size: 15)
    ]

    if viewModel.name == nil {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center
      attributes[.paragraphStyle] = paragraphStyle
    }
    let attributedString = NSMutableAttributedString(string: pointsLabel.text ?? "", attributes: attributes)
    pointsLabel.attributedText = attributedString
    setNeedsLayout()
  }

  private func editMode(activate: Bool) {
   // optionsButton.alpha = activate ? 1 : 0
    if !activate {
      border.removeFromSuperlayer()
      return
    }
    pointsLabel.textColor = AppColors.primary.color
    self.layer.addSublayer(border)
    pointsLabel.isUserInteractionEnabled = activate
  }
}
