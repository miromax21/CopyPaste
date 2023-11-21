//
//  swiper.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 21.04.2023.
//

import UIKit
final class Swiper: UIViewController {

  private var imageview: UIView?
  var swipeButtonWidth: CGFloat = 50.5
  var swiper: UIView!
  var isHidden = true
  var timerView: TimerView?
  var showSwiper: Bool! {
    didSet {
      presentSwiper()
    }
  }
  var outButtonWidth: NSLayoutConstraint!
  private lazy var outButton: UIButton = {
    let settings = ControllSettings(colorType: .text, edgeInsets: 0)
    settings.edgeInsets = (10.0, 0)
    settings.fontSize = 12
    settings.colorType = .error
    let outButton = ViewBuilder(settings: settings).makeButton()
    outButton.onClick = {

    }
    outButton.translatesAutoresizingMaskIntoConstraints = false
    return outButton
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 15
    stackView.alignment = .fill
    stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    return stackView
  }()

  private lazy var blure: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    blurView.frame = view.frame
    return blurView
  }()

  private var subviewWidth: NSLayoutConstraint!
  private var swipeWidth: NSLayoutConstraint!
  private var subviewItemWidth: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.translatesAutoresizingMaskIntoConstraints = false
  }

  init(with subviews: [UIView], swiperView: UIView, title: String) {
    super.init(nibName: nil, bundle: nil)
    configure(swiperView: swiperView, title: title)
    configure(subviews: subviews)
    view.layoutIfNeeded()

    swiper.layer.cornerRadius = 8
    swiper.layer.cornerRadius = 25
    swiper.clipsToBounds = true
    swiper.backgroundColor = AppColors.lightGray.color
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    view.insertSubview(blure, at: 1)
    blure.frame = view.frame
    self.showSwiper = false

  }

  @objc private func handleGesture(gesture: UISwipeGestureRecognizer) {
    showSwiper = gesture.direction == .left
  }

}

// MARK: - configure
private extension Swiper {
  func configure(swiperView: UIView, title: String) {
    (swiperView as? UIImageView)?.contentMode = .scaleAspectFit
    swiperView.tintColor = AppColors.inactiveText.color
    self.imageview = swiperView
    let swiper = UIView()
    swiper.addSubview(swiperView)
    outButton.setTitle(title, for: .normal)

    swiper.addSubview(outButton)
    [swiperView, outButton].forEach {
      swiper.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: $0)
    }
    outButtonWidth = outButton.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
    outButtonWidth.isActive = true
    swiper.addConstraintsWithFormat("H:|-10-[v0(40)]-(>=0)-[v1]-10-|", views: swiperView, outButton)
    swiper.layer.cornerRadius = 20
    swiper.clipsToBounds = true
    self.swiper = swiper

  }

  func configure(subviews: [UIView]) {
    view.addSubview(stackView)

    var conf: (str: String, range: [UIView]) = ("", [])
    let count = subviews.count
    subviews.enumerated().forEach {
      let index = $0.offset
      stackView.addArrangedSubview($0.element)
      conf.str += "[v\(index)\(index > 0 ? "(==v0)": "")]\(index == count - 1 ? "" : "-")"
      conf.range.append($0.element)
      $0.element.layer.cornerRadius = 25
    }
    view.addSubview(swiper)

    swipeWidth = swiper.widthAnchor.constraint(equalToConstant: 60)
    swipeWidth.isActive = true
    [stackView, swiper].forEach {
      view.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: $0)
    }
    view.addConstraintsWithFormat("H:|-24-[v0]-[v1]-24-|", views: stackView, swiper)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    swiper.translatesAutoresizingMaskIntoConstraints = false
    typealias Dir = UISwipeGestureRecognizer.Direction
    [Dir.left, Dir.right].forEach {
      let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
      swipeRight.direction = $0
      self.swiper.addGestureRecognizer(swipeRight)
    }
  }

}
// MARK: - configure view

private extension Swiper {

  func addTimerAnimation() {
    timerView = TimerView(type: .withIcon(.none))
    swiper.addSubview(timerView!)
    timerView?.center = imageview!.center
    timerView!.contentMode = .scaleAspectFit
    timerView!.render()
    timerView!.start(timeInterval: 6)
    timerView!.bringSubviewToFront(imageview!)
    timerView?.alpha = showSwiper ? 1 : 0
    timerView?.complete = { [weak self] in
      self?.showSwiper = false
    }
  }

  func presentSwiper() {
    swipeWidth.constant = showSwiper ? 145 : 60
    outButtonWidth.constant = showSwiper ? 100 : 0
    if !showSwiper {
      imageview?.alpha = 1
      timerView?.removeFromSuperview()
      timerView?.stop()
    }
    UIView.animate(withDuration: 0.3, delay: showSwiper ? 0 : 0) { [self] in
      outButton.isHidden = !showSwiper
      view.backgroundColor = showSwiper ? AppColors.lightGrayAny.color(alpha: 40) : .none
      swiper.tintColor =  showSwiper ? AppColors.alertError.color(alpha: 70) : AppColors.lightGray.color
      view.layoutIfNeeded()
    } completion: { [self] _ in
      if showSwiper {
        imageview?.alpha = 0.3
        addTimerAnimation()
      }
    }
  }
}
