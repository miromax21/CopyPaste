//
//  Fonts.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 04.10.2022.
//

import Foundation
import UIKit
enum FontNamesEnum: String {
  case base = "System"
}

enum FontsStyle: String {
    case normal = ""
    case regular = "Regular"
    case bold = "Bold"
    case italic = "Italic"
}

enum FontsEnum {
    case base
    case custom(name: FontNamesEnum, style: FontsStyle)

    func getFont(size: CGFloat) -> UIFont {
        let (name, style) = self.options
        let font = UIFont(name: name + "-" + style, size: size)
                ?? UIFont(name: name, size: size)
                ?? UIFont.systemFont(ofSize: size)
        return font
    }

    private var options: (name: String, style: String) {
        switch self {
        case .base:
            return (FontNamesEnum.base.rawValue, FontsStyle.normal.rawValue)
        case .custom(name: let name, let style):
            return (name.rawValue, style.rawValue)
        }
    }
}
