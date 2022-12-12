//
//  ToatView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
struct ToatOptions {
  var icon: IconTypeEnum?
  var margins: CGFloat   = 20
  var fromTop: Bool      = true
  var fullWidth: Bool      = false
  var timeInterval: Double    = 3.5
}

protocol ToatProtocol {
  var complete    : (() -> Void)! {get set}
  func toogle(showAlert: Bool)
  func initView(alert: AlertService.AlertType, window: UIWindow?, font: UIFont, viewOptions: ToatOptions?)
}

final class Toat: ToatProtocol {
  var complete    : (() -> Void)!
  var options: ToatOptions               = ToatOptions()
  var messages: [AlertService.AlertType]  = [AlertService.AlertType]()
  var addHeader: Bool                      = false
  var alertTimer: Timer?
  var nextOptions: ToatOptions?

  lazy var toastLbl: UILabel = {
    let tLabel                  = UILabel()
    tLabel.textAlignment        = .center
    tLabel.font                 = FontsEnum.base.getFont(size: 20)
    tLabel.textColor            = ElementsColorsEnum.white.color
    tLabel.numberOfLines        = 0
    tLabel.lineBreakMode        = .byWordWrapping
    tLabel.textColor            = AppColors.white.color
    tLabel.baselineAdjustment   = .alignCenters
    tLabel.layoutIfNeeded()
    tLabel.translatesAutoresizingMaskIntoConstraints = false
    return tLabel
  }()

  lazy var toastView: UIView = {
    let tView               = UIView()
    tView.clipsToBounds     = true
    tView.backgroundColor   = UIColor.black.withAlphaComponent(0.8)
    tView.alpha = 0
    tView.layoutIfNeeded()
    return tView
  }()

  lazy var header: UILabel  = {
    let label = PaddingLabel(10, 10, 35, 10)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = AppColors.white.color
    label.layer.borderWidth = 1
    return label
  }()

  lazy var statusView: StatusView = {
    let statusView = StatusView()
    statusView.setSattus(frame: CGRect(x: 10, y: 10, width: 20, height: 20), status: .notifications)
    return statusView
  }()

  func initView(alert: AlertService.AlertType, window: UIWindow?, font: UIFont, viewOptions: ToatOptions? = nil) {
    self.options = viewOptions ?? ToatOptions()
    guard let alertWindow = window else {return}

    if let title = alert.value.header {
      header.backgroundColor = alert.value.bgColor
      header.text = title
      addHeader   = true
    }

    alertWindow.addSubview(toastView)
    toastLbl.text = alert.value.message
    toastLbl.setNeedsLayout()
    toastLbl.sizeToFit()
    configure(window: alertWindow)

    var viewsArray = [(target: toastLbl, fullWidth: false)]
    statusView.removeFromSuperview()
    if addHeader {
      statusView.status = options.icon
      statusView.colors = alert.headerValues?.iconColors
      header.textColor = alert.headerValues?.textColor.color
      header.addSubview(statusView)
      viewsArray.insert( (target: header, fullWidth : true), at: 0)
    }

    viewsArray.enumerated().forEach {
      toastView.addSubview($0.element.target)
      if $0.offset == 0 {
        $0.element.target.topAnchor.constraint(equalTo: toastView.topAnchor, constant: -1).isActive = true
        $0.element.target.heightAnchor.constraint(equalToConstant: 40).isActive = addHeader
      } else if $0.offset  == viewsArray.count - 1 {
        $0.element.target.bottomAnchor.constraint(
          equalTo: toastView.bottomAnchor,
          constant: -options.margins / 2
        ).isActive = true
      }
      if $0.offset > 0 {
        $0.element.target.topAnchor.constraint(
          equalTo: toastView.subviews[$0.offset - 1].bottomAnchor,
          constant: 0
        ).isActive = true
      }
      let margin = $0.element.fullWidth ? -1 : options.margins / 2
      $0.element.target.leftAnchor.constraint(equalTo: toastView.leftAnchor, constant: margin).isActive = true
      $0.element.target.rightAnchor.constraint(equalTo: toastView.rightAnchor, constant: -margin).isActive = true
    }
    toastView.needsUpdateConstraints()
    toastView.setNeedsLayout()
    toastView.center.x = alertWindow.center.x
  }

  private func configure(window: UIWindow) {
    let textSize = toastLbl.intrinsicContentSize
    let titleSize = header.intrinsicContentSize
    let labelHeight = ( textSize.width / window.frame.width ) * 30

    let labelWidth = min(
      max(
        textSize.width  + 2 * options.margins,
        titleSize.width + 2 * options.margins
      ),
      window.frame.width - ( options.fullWidth ? 0 :  2 * options.margins)
    )
    let adjustedHeight = max(labelHeight, textSize.height + options.margins)

    let yPosition = options.fromTop
      ? options.fullWidth ? 0 : 20
      : window.frame.height - 90 - adjustedHeight

    toastView.frame =  CGRect(
      x: options.margins / 2,
      y: yPosition,
      width: options.fullWidth ? window.frame.width : labelWidth + options.margins,
      height: adjustedHeight + 2 * options.margins + labelHeight
    )
    toastView.layer.cornerRadius = options.fullWidth ? 0 : 12
    toastLbl.translatesAutoresizingMaskIntoConstraints = false
    self.toastView.setNeedsLayout()
  }

  func toogle(showAlert: Bool = true) {
    alertTimer?.invalidate()

    let jump: CGFloat = options.fromTop ? (options.fullWidth ? 0 : 20) : -20
    let duration = showAlert ? 1 : 0.5

    UIView.animate(
      withDuration: duration,
      delay: 2 * duration,
      options: .curveEaseOut,
      animations: { [weak self] in
        guard let self = self else {return}
        self.toastView.transform = CGAffineTransform(translationX: 0, y: showAlert ? jump : -jump)
        self.toastView.alpha = showAlert ? 1 : 0
      },
      completion: { [weak self] _ in
        if let self = self, !showAlert {
          self.toastView.removeFromSuperview()
          self.complete()
        }
      })
    if !showAlert {
      return
    }

    self.alertTimer = Timer.scheduledTimer(
      timeInterval: TimeInterval(self.options.timeInterval),
      target: self,
      selector: #selector(self.cancelTimer),
      userInfo: nil,
      repeats: false
    )
  }

  @objc func cancelTimer(notification: NSNotification) {
    toogle(showAlert: false)
  }
}
