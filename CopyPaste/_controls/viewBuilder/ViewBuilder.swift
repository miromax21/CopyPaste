//
//  ButtonSettings.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.10.2022.
//

import UIKit

final class ViewBuilder {
  private var settings: ControllSettings!

  private func setSettings(settings: ControllSettings) {
    self.settings = settings
  }

  init(icon: ButtonStyleEnum) {
    setSettings(settings: icon.settings)
  }
  init(title: String? = nil, settings: ControllSettings) {
    settings.title = title
    setSettings(settings: settings)
  }

  init(title: String? = nil, style: ButtonStyleEnum! = .filled) {
    let settings = style.settings
    if let title = title {
      settings.title = title
    }
    setSettings(settings: settings)
  }

  func setColors(colorType: ColorType? = nil) -> Self {
    guard let settings = settings else { return self }
    settings.colorType = colorType
    setSettings(settings: settings)
    return self
  }

  func makeButton(customisation: Customisation? = nil, area: CGFloat? = nil) -> CustomButton {
    var button: CustomButton!
    if let area = area {
      settings.edgeInsets = (area, area)
    }
    button = CustomButton(settings: settings)
    let customisation = customisation ?? Customisation(fontSize: settings.fontSize)
    if let titleLabel = button.titleLabel {
      var titleAttributes = customisation.attributes
      titleAttributes[.font] = FontsEnum.custom(name: .system, style: .bold).getFont(size: customisation.fontSize)
      let attributedString = NSMutableAttributedString(string: titleLabel.text ?? "", attributes: titleAttributes)
      titleLabel.attributedText = attributedString
    }

    return button
  }

  func makeTextField(placeholder: String, delegate: UITextFieldDelegate? = nil) -> TextField {
    let textField = TextField(placeholder: placeholder, delegate: delegate)
    textField.configure(settings: settings)
    return textField
  }
}

struct Customisation {
  var fontSize: CGFloat = 16
  var attributes: [NSAttributedString.Key: Any] = [:]
}
