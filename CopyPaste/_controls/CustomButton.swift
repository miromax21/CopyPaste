//
//  CustomButton.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit

class CustomButton: UIButton {

  var useDisabledSatate = false
  var onClick: (() -> Void)?
  var isAccent = false

  var onlyBorder: Bool = false {
    willSet {
      if newValue {
        backgroundColor = .clear
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = background.cgColor
      }
    }
  }

  var isDisabled: Bool = false {
    willSet {
      useDisabledSatate = newValue
      self.isEnabled = !newValue
      setColors(immediately: newValue)
    }
  }

  var background: UIColor {
    if useDisabledSatate {
      return .gray
    }
    return isAccent ? .red : .white
  }

  var color: UIColor {
    return .darkGray
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure(view: self)
    startAnimatingPressActions()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    makeButton(view: self)
    startAnimatingPressActions()
  }

  func configure(view: UIView) {
    makeButton(view: view)
  }

  func makeButton(view: UIView) {
    let (width, height) = (CGFloat(250), CGFloat(40))
    let (vWidth, vHeight) = (view.frame.width, view.frame.height)
    self.frame = CGRect(x: vWidth / 2 - width / 2, y: vHeight - self.frame.height, width: width, height: height)
    self.layer.cornerRadius = 5
    if self.backgroundColor == nil {
      backgroundColor = self.background
      tintColor = self.color
    }
  }

  // MARK: - touch animation
  func startAnimatingPressActions() {
    addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
    addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
  }

  @objc private func animateDown(sender: UIButton) {
    animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
  }

  @objc private func animateUp(sender: UIButton) {
    animate(sender, transform: .identity, completion: onClick)
  }

  private func setColors(immediately: Bool = false) {
    UIView.animate(
      withDuration: immediately ? 0.2 : 1.0,
      delay: 0.0,
      options: [.curveEaseIn],
      animations: { [unowned self] in
        self.backgroundColor = self.background
        self.tintColor = self.color
      }
    )
  }

  func setShadow () {
    layer.shadowColor = AppColors.black.color.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 4.0)
    layer.shadowOpacity = 0.4
    layer.shadowRadius = 4.0
  }

  private func animate(_ button: UIButton, transform: CGAffineTransform, completion: (() -> Void)? = nil) {
    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 3,
      options: [.curveEaseInOut],
      animations: {
        button.transform = transform
      }, completion: { _ in
        if let completion = completion {
          completion()
        }
      }
    )
  }
  func setFont(font: UIFont) {
    self.titleLabel?.font = font
  }
}
