//
//  SliderModel.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 16.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import Foundation
import UIKit
struct SliderModel: Decodable {
  var imageName: String = ""
  var title: String = ""
  var message: String = ""
  var image: UIImage {
    return  UIImage(named: imageName) ?? UIImage()
  }
}
