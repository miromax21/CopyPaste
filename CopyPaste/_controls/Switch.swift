//
//  Switch.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import UIKit

class UICustomSwitch: UISwitch {

  var onColor: UIColor! = .yellow
  var offColor: UIColor! = .gray
  var background: UIColor! = AppColors.white.color

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpCustomUserInterface()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.setUpCustomUserInterface()
  }

  func setUpCustomUserInterface() {
    DispatchQueue.main.async { [unowned self] in
      layer.masksToBounds = false
      layer.cornerRadius = self.bounds.height / 2
      addTarget(self, action: #selector(UICustomSwitch.updateUI), for: UIControl.Event.valueChanged)
      onTintColor = background
      subviews[0].subviews[0].backgroundColor = background
      setShadow()
      self.updateUI()
    }
  }

  func setShadow () {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    layer.shadowColor = UIColor.lightGray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = 0.2
    layer.shadowRadius = 3.5
  }

  func setState(isOn: Bool, isEnabled: Bool? = nil) {
    if isEnabled != nil {
      self.isEnabled = isEnabled!
    }
    if self.isOn == isOn {
      return
    }
    self.isOn = isOn
    updateUI()
  }

  @objc func updateUI() {
    UIView.animate(withDuration: 1.0, animations: { [unowned self] in
      thumbTintColor = isOn ? onColor : offColor
    })
  }
}
