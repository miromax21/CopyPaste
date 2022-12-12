//
//  Colors.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
typealias AppColors = ElementsColorsEnum
enum ElementsColorsEnum: String {
    case white,
         black,
         alertError,
         alertInfo,
         alertWarning

    func color(alpha: Int = 100) -> UIColor {
        let colorAlpha = CGFloat(alpha) / 100
        let color = UIColor(named: self.rawValue)!.withAlphaComponent(colorAlpha)
        return color
    }
    var color: UIColor {
        return UIColor(named: self.rawValue)!
    }
}
