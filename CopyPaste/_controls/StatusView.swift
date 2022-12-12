//
//  StatusView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
class StatusView: UIImageView {

  var bigButton = false

  var status: IconTypeEnum? {
    willSet {
      guard let newValue = newValue else {
        return
      }
      setSatus(status: newValue)
    }
  }

  var colors : (tint: AppColors, background: AppColors?)? {
    willSet {
      guard let newValue = newValue else {
        return
      }
      backgroundColor = newValue.background?.color ?? .none
      tintColor = newValue.tint.color
    }
  }

  func setSattus(frame: CGRect, status: IconTypeEnum) {
    self.frame = frame
    initIcon(status: status)
  }

  func setSatus(status: IconTypeEnum) {
    initIcon(status: status)
  }

  private func initIcon(status: IconTypeEnum, tint: UIColor = .white) {
    if status  == .none {
      self.image = nil
      return
    }
    self.image = status.icon
    self.contentMode = .scaleAspectFit
    self.layer.cornerRadius = self.bounds.width / 2
    self.clipsToBounds = true
    self.layer.cornerRadius = self.frame.height / 2
  }
}
