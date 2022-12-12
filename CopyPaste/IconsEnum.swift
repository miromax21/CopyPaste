//
//  IconsEnum.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
private var iconPrefix = "icon-"
enum IconTypeEnum: String {
  case none, pause, play, check, warning, back, notifications

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
    return  image.resizeImage(targetSize: CGSize(width: width, height: height))
  }
}
