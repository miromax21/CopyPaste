//
//  CustomButton.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 03.10.2022.
//

import UIKit

class CustomButton: UIButton {

  private var borderLine: CAShapeLayer?

  var settings: ControllSettings!
  var metaData: [String: Any]?
  var onClick: (() -> Void)?
  var controlState: ControllStates! {
    didSet {
      self.isEnabled = controlState == .disabled
      setColors()
    }
  }

  var customSubview: UIView? {
    didSet {
      guard let customSubview = customSubview, oldValue == nil else {
        return
      }
      addSubview(customSubview)
    //  customSubview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
      customSubview.translatesAutoresizingMaskIntoConstraints = false
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  convenience init(settings: ControllSettings) {
    self.init(frame: .zero)
    self.settings = settings
    configure()
    buildUI()
  }

  func setOnlyimage(targetView: UIView, settings: ControllSettings) {
    contentMode = .center
    targetView.contentMode = .center
    titleLabel?.removeFromSuperview()
    let verticalPadding = settings.edgeInsets?.vertical ?? 0
    let horizontalPadding = settings.edgeInsets?.horizontal ?? 0
    addConstraintsWithFormat("H:|-(p)-[v0]-(p)-|", metrics: ["p": horizontalPadding], views: targetView)
    addConstraintsWithFormat("V:|-(p)-[v0]-(p)-|", metrics: ["p": verticalPadding], views: targetView)
  }

  func configure() {
    settings.customize?(self)
    setColors()
    startAnimatingPressActions()
    if settings.useBase == true {
      self.setImage(settings.subviews?.iconImage, for: .normal)
      self.setImage(settings.subviews?.iconImageSelected, for: .selected)
    }
    if let title = settings.title {
      self.setTitle(title, for: .normal)
    }
    titleLabel?.clipsToBounds = true
    titleLabel?.adjustsFontSizeToFitWidth = false
    titleLabel?.lineBreakMode = .byTruncatingTail
    titleLabel?.clipsToBounds = true
    layer.cornerRadius = settings.cornerRadius
    if let (vei, hei) = settings.edgeInsets {
      contentEdgeInsets = UIEdgeInsets(top: vei, left: hei, bottom: vei, right: hei)
    }
  }

  private func buildUI() {
    self.clipsToBounds = true
    if settings.useBase {
      return
    }
    guard
      let params = settings.subviews,
      params.view != nil || params.iconImage != nil
    else { return }
    customSubview = params.view ?? UIImageView(image: params.iconImage)
    guard let customSubview = customSubview else {
      return
    }
    if let degree = settings.subviewAngle  {
      customSubview.transform = CGAffineTransform.identity.rotated(by: Double(degree) * .pi / 180)
    }

    if params.float == .onlyimage || settings.title == nil {
      setOnlyimage(targetView: customSubview, settings: settings)
      return
    }

    let verticalPadding = settings.edgeInsets?.vertical ?? 0
    let imageOffset = CGFloat(params.margin + params.width)
    if params.float == .left {
      contentEdgeInsets.left = verticalPadding + imageOffset
      contentEdgeInsets.right = verticalPadding
    } else if params.float == .right {
      contentEdgeInsets.left = verticalPadding
      contentEdgeInsets.right = verticalPadding + imageOffset
    }

    if let titleLabel = titleLabel {
      titleLabel.sizeToFit()

      customSubview.translatesAutoresizingMaskIntoConstraints = false

      var needToHideText = false
      if let width = titleLabel.attributedText?.width(withConstrainedHeight: settings.fontSize) {
        needToHideText = width <  params.hideTextRatio
      }
      titleLabel.alpha = needToHideText ? 0 : 1

      if params.float == .onlyimage {

        customSubview.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        customSubview.center = self.center
      } else {
        addConstraintsWithFormat("V:[v0(h)]", metrics: ["h": Int(params.height ?? 20)], views: customSubview)
        addConstraintsWithFormat(
          params.horizontslConstraint(buttonPadding: settings.edgeInsets?.horizontal ?? 0),
          options: .alignAllCenterY,
          views: [customSubview, titleLabel]
        )
      }
    }
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let edges = settings.edgeInsets
    return bounds.insetBy(dx: -(edges?.horizontal ?? 0), dy: -(edges?.vertical ?? 0)).contains(point)
  }

// MARK: - touch animation
  func startAnimatingPressActions() {
    addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
    addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
  }

  @objc private func animateDown(sender: UIButton) {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
      sender.alpha = 0.6
    })
  }

  @objc private func animateUp(sender: UIButton) {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
      sender.alpha = 1
    }, completion: { [self] _ in
      onClick?()
    })
  }
}

extension CustomButton {
  private func setColors() {
    checkMakeBorderLine()

    guard  let colorType = settings.colorType else {
      fatalError("there isn't colorType in \(self)")
    }
    let colors = colorType.getColors(disabled: controlState == .disabled, error: controlState == .error )
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) { [self] in
      setTitleColor(colors.tint, for: .normal)
      setTitleColor(colors.tint, for: .disabled)

      switch colorType {
      case .bordered: layer.borderColor = colors.target?.cgColor
      case .text: borderLine?.backgroundColor = UIColor.clear.cgColor
      default:
          backgroundColor = colors.target
          tintColor = colors.tint
      }
    }
  }

  private func checkMakeBorderLine() {
    if settings.colorType != .text, borderLine != nil {
      return
    }
    let shapeLayer = CAShapeLayer()
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: bounds.height))
    path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = AppColors.text.color.cgColor
    shapeLayer.lineWidth = 1
    borderLine = shapeLayer
  }

  func setFont(font: UIFont) {
    self.titleLabel?.font = font
  }
}
