//
//  Field.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 26.10.2022.
//

import Foundation
import UIKit

final class TextField: UITextField {
  private(set) var colorType: ColorType!
  private let colorAnimation = CABasicAnimation(keyPath: "borderColor")
  private var borderLine: CAShapeLayer?

  var filterActions: [UIResponderStandardEditActions]?
  var controlState: ControllStates! {
    didSet { setColors()  }
  }

  convenience init(
    placeholder: String = "",
    delegate: UITextFieldDelegate? = nil,
    filterActions: [UIResponderStandardEditActions]? = nil
  ) {
    self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    self.delegate = delegate
    self.placeholder = placeholder
    autocorrectionType = .no
    autocapitalizationType = .none
  }

  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if NSStringFromSelector(action) == "_showKeyboard" {
      return  true
    }
    return false
  }
  func configure(settings: ControllSettings, state: ControllStates? = nil) {
    self.colorType = settings.colorType
    baseConfiguraton(cornerRadius: settings.corner.radius, padding: settings.edgeInsets?.vertical)
    controlState = state ?? .active
  }
}

// MARK: - extension TextField
private extension TextField {
   func setColors() {
    checkMakeBorderLine()
    guard let colors = colorType?.getColors(disabled: controlState == .disabled, error: controlState == .error )else {
      fatalError("there isn't colorType in \(self)")
    }
    switch colorType {
    case .bordered: layer.borderColor = colors.target?.cgColor
    default: textColor = colors.tint
    }
    colorAnimation.fromValue = colorType?.getColors(disabled: true)
    colorAnimation.toValue = colors.target?.cgColor
    colorAnimation.duration = 0.5
  }

  func checkMakeBorderLine() {
    if colorType != .text, borderLine != nil {
      return
    }
    let shapeLayer = CAShapeLayer()
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: bounds.height))
    path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = AppColors.text.color.cgColor
    shapeLayer.lineWidth = 1
    borderLine = shapeLayer
  }

  private func baseConfiguraton(cornerRadius: CGFloat = 10, padding: CGFloat? = nil) {
    layer.cornerRadius = cornerRadius
    layer.borderWidth = 1.0
    layer.masksToBounds = true
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding ?? 20, height: 10))
    rightView = paddingView
    leftView = paddingView
    rightViewMode = .always
    leftViewMode = .always
    layer.add(colorAnimation, forKey: colorAnimation.keyPath)
  }
}
