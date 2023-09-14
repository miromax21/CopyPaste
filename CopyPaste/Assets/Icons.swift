//
//  Icons.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 25.10.2022.
//

import UIKit
private var iconPrefix = "icon-"

enum IconEnum: String {
  // swiftlint:disable:next identifier_name
  case none, home, notification, ststistic, settings, tv, qrCode, arrow

  var icon: UIImage? {
    if self == .none {
      return nil
    }
    return UIImage(named: "\(iconPrefix)\(self.rawValue)")?.withRenderingMode(.alwaysTemplate)
  }

  var iconName: String {
    return "\(iconPrefix)\(self.rawValue)"
  }

  func getIcon(width: CGFloat, height: CGFloat) -> UIImage? {
    guard let image = self.icon else { return nil}
    return  image
  }
}
