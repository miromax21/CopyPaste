//
//  extension.UIView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 01.11.2022.
//

import UIKit
extension UIView {
  func addConstraintsWithFormat(_ format: String,
                                options opts: NSLayoutConstraint.FormatOptions = [],
                                metrics: [String: Any]? = nil,
                                views: UIView...
  ) {
    addConstraintsWithFormat(format, options: opts, metrics: metrics, views: views)
  }
  func addConstraintsWithFormat(_ format: String,
                                options opts: NSLayoutConstraint.FormatOptions = [],
                                metrics: [String: Any]? = nil,
                                views: [UIView]
  ) {
    addConstraints(
      makeConstraint(format, options: opts, metrics: metrics, views: views)
    )
  }
  
  func makeConstraint(_ format: String,
                      options opts: NSLayoutConstraint.FormatOptions = [],
                      metrics: [String: Any]? = nil,
                      views: [UIView]) -> [NSLayoutConstraint] {
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewsDictionary[key] = view
    }
    return NSLayoutConstraint.constraints(
      withVisualFormat: format,
      options: opts,
      metrics: metrics,
      views: viewsDictionary
    )
  }

  func roundCorners(_ maskedCorners: CACornerMask, radius: CGFloat) {
    self.clipsToBounds = true
    self.layer.cornerRadius = radius
    self.layer.maskedCorners = maskedCorners
  }
}
