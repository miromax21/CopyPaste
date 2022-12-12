//
//  HorizontalProgressBar.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit

class HorizontalProgressBar: UIView {

  var progress: Int = -1 {
    willSet {
      if newValue >= 0 {
        loadingLayer.removeFromSuperlayer()
      }
      progressLayer.removeFromSuperlayer()
      progressValue = Double(newValue)
      setValue(percents: CGFloat(newValue) / 100)
      setNeedsDisplay()
    }
  }

  private var durations: Double = 0.0
  private let cornerRadius: CGFloat = 6.0
  private var progressValue: Double = 0
  private let progressLayer = CALayer()
  private let backgroundMask = CAShapeLayer()

  lazy var loadingLayer: CAGradientLayer  = {
    let loadingLayer = CAGradientLayer()
    loadingLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
    loadingLayer.endPoint = CGPoint(x: 1, y: 0.0)
    loadingLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
    loadingLayer.locations = [0, 0.5, 1]

    let animation = CABasicAnimation(keyPath: "transform.translation.x")
    animation.fromValue = -2 * layer.bounds.width
    animation.toValue =  layer.bounds.width
    animation.duration = 2
    animation.repeatCount = Float.infinity
    loadingLayer.add(animation, forKey: "flowAnimation")
    return loadingLayer
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  func configure(durations: Double = 0.0) {
    self.durations = durations
    layer.addSublayer(loadingLayer)
  }

  func clean() {
    progressLayer.removeFromSuperlayer()
  }

  private func setValue(percents: CGFloat) {
    let width = self.frame.width * percents
    DispatchQueue.main.asyncAfter(deadline: .now() + self.durations) { [weak self] in
      guard let self = self else {return}
      UIView.animate(
        withDuration: 0,
        delay: 0,
        options: .curveEaseOut,
        animations: {
          self.progressLayer.frame.size.width = width > 0 ? width : 0
          self.progressLayer.layoutIfNeeded()
          self.layer.addSublayer(self.progressLayer)
        }
      )
    }
  }

  override func draw(_ rect: CGRect) {

    backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
    layer.mask = backgroundMask
    progressLayer.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: rect.height))

    progressLayer.backgroundColor =
      progressValue == 100
        ? AppColors.black.color(alpha: 70).cgColor
        : AppColors.black.color.cgColor

    progressLayer.cornerRadius = cornerRadius
    loadingLayer.frame = CGRect(x: 0, y: 0, width: rect.width * 2.5, height: rect.height)
  }
}
