//
//  Fonts.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
enum FontNamesEnum: String {
    case system = "System"
}

enum FontsStyle: String {
    case normal = ""
    case regular = "Regular"
    case bold = "Bold"
    case italic = "Italic"
}

enum FontsEnum {
    case base
    case user(name: FontNamesEnum, style: FontsStyle)

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
            return (FontNamesEnum.system.rawValue, FontsStyle.normal.rawValue)
        case .user(name: let name, let style):
            return (name.rawValue, style.rawValue)
        }
    }
}
