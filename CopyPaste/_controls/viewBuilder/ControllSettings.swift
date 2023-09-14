//
//  ButtonBuilder.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 31.10.2022.
//

import UIKit

enum ButtonStyleEnum {
  case bordered,
       filled,
       text,
       icon(_ : SubviewSettings? = nil, name: IconEnum? = nil, settings: ControllSettings? = nil)

  var settings: ControllSettings {
    switch self {
    case .bordered: return bordered()
    case .filled: return filled()
    case .icon(let subviewSettings, let name, let settings):
      return subview(subviewSettings: subviewSettings, name: name, settings: settings)
    case .text: return text()
    }
  }
  private func bordered() -> ControllSettings {
    let settings = ControllSettings()
    settings.colorType = .bordered
    return settings
  }
  private func filled() -> ControllSettings {
    let settings = ControllSettings()
    settings.colorType = .filled
    return settings
  }

  func subview(
    subviewSettings: SubviewSettings? = nil,
    name: IconEnum? = nil,
    settings: ControllSettings? = nil
  ) -> ControllSettings {
    let buttonSettings = settings ?? ControllSettings()
    var subviewSettings = subviewSettings ?? SubviewSettings()
    if subviewSettings.iconImage == nil {
      subviewSettings.iconImage = name?.icon
    }
    buttonSettings.addSubview(subviewsSettings: .withSubview(subviewSettings))
    buttonSettings.colorType = .icon
    return buttonSettings
  }

  private func text() -> ControllSettings {
    let settings = ControllSettings()
    settings.colorType = .text
    return settings
  }
}

final class ControllSettings {
  enum SubviewsSettings {
    case none, withSubview(SubviewSettings?)
    var params: SubviewSettings? {
      switch self {
      case .none: return nil
      case .withSubview(let subview): return subview
      }
    }
  }
  enum CornerEnum {
    case none, base
  }
  private(set) var useBase: Bool = true

  var cornerRadius: CGFloat = 10.0
  var colorType: ColorType!
  var title: String?
  var customize: ((_ button: CustomButton) -> Void)?
  var subviews: SubviewSettings?
  var edgeInsets: (vertical: CGFloat, horizontal: CGFloat)?
  var fontSize: CGFloat = 16
  var corner: CornerEnum = .base
  var useBounds: Bool = false
  var subviewAngle: Int? = nil
  init(colorType: ColorType = .filled, edgeInsets: CGFloat? = 3) {
    self.colorType = colorType
    if let edgeInsets = edgeInsets {
      self.edgeInsets = (edgeInsets, edgeInsets)
    }
  }

  func set(subviews: SubviewSettings?) {
    useBase = false
    self.subviews = subviews
  }
  func addSubview(subviewsSettings: SubviewsSettings?) {
    useBase = false
    self.subviews = subviewsSettings?.params
  }
}

struct SubviewSettings {
  var hideTextRatio: Double = 1
  var margin: Int = 3
  var width: Int = 45
  var height: CGFloat?
  var iconImage: UIImage?
  var iconImageSelected: UIImage?
  var view: UIView?

  var float: SubviewFloating = .left
  func horizontslConstraint(buttonPadding pudding: CGFloat! = 0) -> String {
    var constraint = ""
    switch float {
    case .left: constraint = "H:[v0(\(width))]-(\(margin))-[v1]"
    case .right: constraint = "H:[v1]-(\(margin))-[v0(\(width))]"
    case .onlyimage: constraint = "H:|[v0]|"
    }
    return constraint
  }

  enum SubviewFloating {
    case left, right, onlyimage
  }
}

struct UIButtonColor {
  var color: AppColors?
  var tint: AppColors = .white

  init(color: AppColors? = nil, tint: AppColors? = .white) {
    self.color = color
    self.tint = tint ?? .white
  }
}
