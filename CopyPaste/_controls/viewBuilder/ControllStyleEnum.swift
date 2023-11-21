//
//  ControllStyleEnum.swift
//  CompanionApp
//
//  Created by Maksim Mirono on 09.10.2023.
//

import Foundation
enum ControllStyleEnum {
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
    buttonSettings.corner = .custom(15)
    return buttonSettings
  }

  private func text() -> ControllSettings {
    let settings = ControllSettings()
    settings.colorType = .text
    return settings
  }
}
