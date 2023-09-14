//
//  CalendarCell.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.11.2022.
//

import Foundation
import UIKit

final class CalendarCell: UICollectionViewCell, ConfigureCellProtocol, CAAnimationDelegate {

  typealias CellModel = CalendarDay
  var viewModel: CalendarDay? {
    didSet {
      guard let val = viewModel, val.day > 0
        else { return }
      dayNumber.text = "\(val.day)"
      dayName.text = "\(clendarHelper.weekdayNameFromWeekdayNumber(weekdayNumber: val.day))"
      backgroundColor = val.indication.color.color
    }
  }
  func configure(viewModel: CalendarDay?, config: [String: Any]?) {
    typealias SectionsType = CalendarSectionConfigurator.SectionLayoutEnum
    setDefault()
    self.viewModel = viewModel
    modeType = config?[CalendarSectionConfigurator.SectionLayoutEnum.key] as? String
  }

  var modeType: String? {
    didSet {
      buildView()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.customInit()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.customInit()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    setDefault()
  }

  func setDefault() {
    dayNumber.text = ""
  //  self.alpha = 0
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    addAnimation()
  }

  private var bottomConstraint: NSLayoutConstraint?
  private var dayNameheightConstraint: NSLayoutConstraint!
  private var dayNumberheightConstraint: NSLayoutConstraint!
  private var maxWidth: NSLayoutConstraint!

  private var sizeView: UIView = {
    var view = UIView()
    view.clipsToBounds = true
    view.layer.cornerRadius = 10
    return view
  }()

  let gradientChangeAnimation = CABasicAnimation(keyPath: "transform.translation.y")

  private lazy var gradientLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.backgroundColor = UIColor.red.cgColor
    layer.cornerRadius = 10
    return layer
  }()

  private lazy var dayNumber: UILabel = {
    let dayNumber: UILabel! = UILabel()
    dayNumber.minimumScaleFactor = 0.8
    dayNumber.adjustsFontSizeToFitWidth = true
    dayNumber.textAlignment = .center
    dayNumber.numberOfLines = 2
    return dayNumber
  }()

  private lazy var dayName: UILabel = {
    let dayName: UILabel! = UILabel()
    dayName.font = FontsEnum.base.getFont(size: 12)
    dayName.textColor = AppColors.backgroundSubview.color
    dayName.adjustsFontSizeToFitWidth = true
    dayName.textAlignment = .center
    return dayName
  }()

  private func customInit() {
    layoutIfNeeded()
    [sizeView, dayNumber, dayName].forEach {addSubview($0)}
    initConstraints()

    dayName.bringSubviewToFront(sizeView)
   // sizeView.layer.addSublayer(gradientLayer)
    sizeView.layer.insertSublayer(gradientLayer, at: 0)
    gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
    gradientChangeAnimation.isRemovedOnCompletion = false
    modeType = CalendarSectionConfigurator.SectionLayoutEnum.calendar(nil).type
    buildView()

    let path = UIBezierPath()
    path.move(to: CGPoint(x: sizeView.frame.width, y: sizeView.frame.height))
    path.addLine(to: CGPoint(x: sizeView.frame.width, y: sizeView.frame.height))
    gradientLayer.path = path.cgPath
  }

}

extension CalendarCell {
  private var clendarHelper: CalendarHelper {
    CalendarHelper()
  }
  private var textHeight: CGFloat {
    return 20
  }
  private func addAnimation() {
    let position = CGFloat(viewModel?.value ?? 0)
    let statisticViewHeight = sizeView.frame.height * position / 100
    if modeType == "calendar" {
      self.layer.cornerRadius = self.frame.height / 2
      maxWidth.constant = frame.width
    }
    if modeType == "graphic" {
      maxWidth.constant = textHeight
      self.layer.cornerRadius = 0
      gradientLayer.frame = sizeView.frame

      let animation = CABasicAnimation(keyPath: "size.height")
      animation.fromValue = 0
      animation.toValue = 0
      animation.duration = position

      animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
      animation.fillMode = CAMediaTimingFillMode.both
      animation.isRemovedOnCompletion = false
      gradientLayer.add(animation, forKey: animation.keyPath)

      gradientLayer.add(animation, forKey: nil)

      gradientLayer.frame = CGRect(origin: .init(x: 0, y: 0), size: CGSize(width: 20, height: statisticViewHeight))
      gradientChangeAnimation.fromValue = sizeView.frame.height
      gradientChangeAnimation.toValue = sizeView.frame.height - statisticViewHeight
      gradientLayer.add(gradientChangeAnimation, forKey: "show")
    }
  }

  private func buildView() {
    bottomConstraint?.constant = modeType == "calendar" ? 20 : -20
    clipsToBounds = true
    if modeType == "graphic" {
      buildGraphicView()
    } else if modeType == "calendar" {
      buildCalendarView()
    }

    bottomConstraint?.isActive = true
    sizeView.sendSubviewToBack(dayNumber)
    setNeedsLayout()
  }

  private func buildGraphicView() {
    sizeView.alpha = 1
    dayNameheightConstraint.constant = 10
    dayNumberheightConstraint.constant = 10
    dayName.alpha = 1
    sizeView.backgroundColor = AppColors.primary.color
    gradientLayer.backgroundColor = viewModel?.indication.color.color.cgColor
  }

  private func buildCalendarView() {
    gradientLayer.backgroundColor = nil
    sizeView.backgroundColor = viewModel?.indication.color.color
    dayNameheightConstraint.constant = 5
    dayNumberheightConstraint.constant = 20
    dayName.alpha = 0
  }

  private func initConstraints() {
     dayNameheightConstraint = NSLayoutConstraint(
      item: dayName,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: textHeight
    )
    dayNumberheightConstraint = NSLayoutConstraint(
      item: dayNumber,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: textHeight
    )

    maxWidth = NSLayoutConstraint(
      item: sizeView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1,
      constant: frame.width
    )

    dayName.addConstraint(dayNameheightConstraint)
    dayNumber.addConstraint(dayNumberheightConstraint)
    addConstraintsWithFormat("V:[v0]-[v1]|", views: dayNumber, dayName)
    addConstraintsWithFormat("V:|[v0]", views: sizeView)
    [dayNumber, dayName].forEach { addConstraintsWithFormat("H:|-2-[v0]-2-|", views: $0)}
    sizeView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    bottomConstraint = sizeView.bottomAnchor.constraint(equalTo: dayNumber.bottomAnchor, constant: 0)
    sizeView.addConstraint(maxWidth)
    maxWidth.isActive = true
  }
}
