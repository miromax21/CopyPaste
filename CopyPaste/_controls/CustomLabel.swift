//
//  PaddingLable.swift
//  MediaMetr
//
//  Created by Maksim Mironov on 10.09.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import UIKit
final class CustomLabel: UILabel {

  var topInset: CGFloat
  var bottomInset: CGFloat
  var leftInset: CGFloat
  var rightInset: CGFloat

  private(set) var colorType: ColorType? {
    didSet {
      setColors()
    }
  }

  required init(_ top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
    self.topInset = top
    self.bottomInset = bottom
    self.leftInset = left
    self.rightInset = right
    super.init(frame: CGRect.zero)
  }

  convenience init(settings: ControllSettings) {
    let hInset = settings.edgeInsets?.horizontal ?? 0
    let vInset = settings.edgeInsets?.vertical ?? 0
    self.init(vInset, vInset, hInset, hInset)
    colorType = settings.colorType
    if case .custom(let corner) = settings.corner {
      layer.cornerRadius = corner
      clipsToBounds = true
    }
    font = FontsEnum.base.getFont(size: settings.fontSize)
    text = settings.title
    setColors()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }

  override var intrinsicContentSize: CGSize {
    var contentSize = super.intrinsicContentSize
    contentSize.height += topInset + bottomInset
    contentSize.width += leftInset + rightInset
    return contentSize
  }

  func setColors() {
    if let colorType = colorType {
      textColor = colorType.getColors(disabled: false).tint
      backgroundColor = colorType.getColors(disabled: false).target
    }
  }
}
