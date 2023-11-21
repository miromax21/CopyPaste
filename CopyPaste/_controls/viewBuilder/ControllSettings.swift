//
//  ButtonBuilder.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 31.10.2022.
//

import UIKit
enum ControllStates {
  case active, disabled, error
}
// MARK: ControllSettings -
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
    case none, custom(CGFloat)
    var radius: CGFloat {
      switch self {
        case .custom(let corener): return corener
        default: return 0.0
      }
    }
  }
  private(set) var useBase: Bool = true
  var colorType: ColorType?
  var title: String?
  var customize: ((_ button: CustomButton) -> Void)?
  var subviews: SubviewSettings?
  var edgeInsets: (horizontal: CGFloat, vertical: CGFloat)?
  var fontSize: CGFloat = 16
  var corner: CornerEnum = .custom(15)
  var useBounds: Bool = false

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

// MARK: SubviewSettings -

struct SubviewSettings {
  var contentMode: UIView.ContentMode = .center
  var hideTextRatio: Double = 1
  var margin: Int = 3
  var width: Int = 45
  var height: CGFloat?
  var iconImage: UIImage?
  var iconImageSelected: UIImage?
  var view: UIView?
  var subviewAngle: Int?
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

// MARK: UIButtonColor -

struct UIButtonColor {
  var color: AppColors?
  var tint: AppColors = .white

  init(color: AppColors? = nil, tint: AppColors? = .white) {
    self.color = color
    self.tint = tint ?? .white
  }
}
