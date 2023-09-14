//
//  colorSettings.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 31.10.2022.
//

import Foundation
import UIKit

enum ColorType {
  case bordered, filled, text, icon, lightFilled, error

  func getColors(disabled disabledState: Bool, error: Bool = false) -> (tint: UIColor, target: UIColor?) {
    if error {
      return buildColors(from: UIButtonColor(color: .alertError, tint: .text), withAlpha: nil)
    }
    var colors: UIButtonColor
    switch self {
    case .bordered: colors = UIButtonColor(color: .primary, tint: .text)
    case .filled: colors = UIButtonColor(color: .primary, tint: .white)
    case .text: colors = UIButtonColor(tint: .primary)
    case .icon: colors =  UIButtonColor(color: .text, tint: .backgroundSubview)
    case .lightFilled: colors =  UIButtonColor(color: .lightGray, tint: .inactiveText)
    case .error: colors =  UIButtonColor(color: .lightGray, tint: .alertError)
    }
    return buildColors(from: colors, withAlpha: disabledState ? 80 : nil)
  }

  private func buildColors(from: UIButtonColor, withAlpha: Int?) -> (tint: UIColor, target: UIColor?) {
    if let alpha = withAlpha {
      return (tint: from.tint.color, target: from.color?.color(alpha: alpha))
    }
    return (tint: from.tint.color, target: from.color?.color)
  }
}
