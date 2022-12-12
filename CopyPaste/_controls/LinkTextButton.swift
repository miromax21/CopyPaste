//
//  LinkTextButton.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
struct LinkButtonConfig {
  var lineMarginY: CGFloat = 3.5
  var fontSize: CGFloat = 18
  var title: String?
  var url: String?
}

class LinkTextButton: UIButton {
  var parentView: UIViewController?
  private var open: OpenType?
  private var uiConfig = LinkButtonConfig()
  var useXibInit = false
  var onClick: (() -> Void)?

  var uiConfiguration: LinkButtonConfig? {
    willSet {
      if let conf = newValue {
        configure(with: conf)
      }
    }
  }

  var openIn: OpenType = .app {
    willSet {
      if open != nil {return}
      open = newValue
    }
  }

  var toched: Bool = false {
    willSet {
      UIView.animate(withDuration: 0.1, animations: { [unowned self] in
        self.borderLine?.opacity = newValue ? 0 : 1
      })
    }
  }

  var url: URL?
  var stringUrl: String? {
    willSet {
      if let newValue = newValue, let newUrl = URL(string: newValue) {
        url = newUrl
      }
    }
  }

  lazy var borderLine: CAShapeLayer? = nil

  enum OpenType {
    case app, safari, otherApp, delegate
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    if useXibInit {
      configure()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    if useXibInit {
      configure()
    }
  }

  func configure() {
    self.sizeToFit()
    self.setAttributedTitle(self.attributedString(), for: .normal)
  }

  func configure(with configuration: LinkButtonConfig? = nil) {
    borderLine?.removeFromSuperlayer()
    self.setTitle(configuration?.title ?? "", for: .normal)
    if let urlString = configuration?.url {
      self.url = URL(string: urlString)
    }
    self.uiConfig = configuration ?? LinkButtonConfig()
    configure()
  }

  private func attributedString() -> NSAttributedString? {
    let attributes: [NSAttributedString.Key: Any] = [
      .font: FontsEnum.base.getFont(size: uiConfig.fontSize)
    ]
    let attributedString = NSMutableAttributedString(string: self.currentTitle ?? "", attributes: attributes)
    return attributedString
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isHighlighted = true
    toched = true
    super.touchesBegan(touches, with: event)
    if let url = url {
      UIApplication.shared.open(url, options: [:])
    }
  }

  func makeBorderLine() {
    borderLine?.removeFromSuperlayer()

    guard
      let bounds = self.titleLabel?.frame else  {
      return
    }

    let textHeight = self.titleLabel!.intrinsicContentSize.height - uiConfig.lineMarginY
    let shapeLayer = CAShapeLayer()
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: textHeight))
    path.addLine(to: CGPoint(x: bounds.width, y: textHeight))

    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = AppColors.black.color.cgColor
    shapeLayer.lineWidth = 1
    borderLine = shapeLayer
    self.layer.addSublayer(borderLine!)
    borderLine?.position = CGPoint(x: titleLabel!.frame.origin.x, y: textHeight)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    makeBorderLine()
  }
}
