//
//  extension.UIView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit

extension UIView {
  func addConstraintsWithFormat(
    _ format: String,
    options opts: NSLayoutConstraint.FormatOptions = [],
    metrics: [String: Any]? = nil,
    views: UIView...
  ) {
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewsDictionary[key] = view
    }
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: format,
        options: opts,
        metrics: metrics,
        views: viewsDictionary
      )
    )
  }

  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(
      roundedRect: self.bounds,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
