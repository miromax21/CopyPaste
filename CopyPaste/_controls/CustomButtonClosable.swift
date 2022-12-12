//
//  CustomButtonClosable.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit
enum ButtonTypeEnum {
  case icon, button
}
class CustomButtonClosable: CustomButton {
  var title = "×"
  var iconImage: UIImage!

  private var displayType: ButtonTypeEnum?
  override var background: UIColor {
    if useDisabledSatate {
      return AppColors.white.color
    }
    return isAccent ? AppColors.white.color(alpha: 12) : AppColors.white.color
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configure(view: UIView, type: ButtonTypeEnum = .icon) {
    if displayType != nil && displayType == type {
      return
    }
    displayType = type
    displayType == .icon ? makeIcon(view: view) : makeButton(view: view)
  }

  func configure(iconparent view: UIView, icon: UIImage = #imageLiteral(resourceName: "icon-clear")) {
    self.iconImage = icon
    makeIcon(view: view)
  }

  func configure(iconparent view: UIView, title: String = "", image: UIImage = #imageLiteral(resourceName: "icon-clear")) {
    self.iconImage = image
    self.title = title
    makeIcon(view: view)
  }

  func configure(parent view: UIView, frame: CGRect = CGRect(x: 15, y: 15, width: 30, height: 30)) {
    makeIcon(view: view, frame: frame)
  }

  func makeIcon(view: UIView, frame: CGRect = CGRect(x: 15, y: 15, width: 30, height: 30)) {
    alpha = 0
    displayType = .icon
    isAccent = true
    self.frame = frame
    layer.cornerRadius = frame.height / 2
    setTitle("", for: .normal)
    setImage(iconImage, for: .normal)
    contentVerticalAlignment = .fill
    contentHorizontalAlignment = .fill
    imageView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
    imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    imageView?.sizeToFit()
    backgroundColor = background
    setNeedsLayout()
    animateDisplay(view: view)
  }

  override func makeButton(view: UIView) {
    alpha = 0
    displayType = .button
    isAccent = false
    self.setImage(nil, for: .normal)

    setTitle(title, for: .normal)
    titleLabel?.textAlignment = .center
    backgroundColor = background
    setNeedsLayout()
    super.makeButton(view: view)
    animateDisplay(view: view)
  }

  func animateDisplay(view: UIView) {
    UIView.animate(withDuration: 0.5, animations: { [unowned self] in
      alpha = 1
      var frame: CGRect = frame
      if displayType == .button {
        frame.origin.y = view.frame.height - frame.height - 30
      }
      self.frame = frame
    })
  }
}
