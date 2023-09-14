//
//  Colors.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 09.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import Foundation
import UIKit
typealias AppColors = ElementsColorsEnum
enum ElementsColorsEnum: String {
    case  none,
          black,
          white,
          alertError,
          alertInfo,
          alertWarning,
          backgroundMain,
          backgroundMainReverse,
          text,
          primary,
          shadow,
          lightGray,
          lightGrayAny,
          backgroundSubview,
          inactiveText

    func color(alpha: Int = 100) -> UIColor {
        let colorAlpha = CGFloat(alpha) / 100
        let color = UIColor(named: self.rawValue)!.withAlphaComponent(colorAlpha)
        return color
    }
    var color: UIColor {
        return UIColor(named: self.rawValue)!
    }

}
