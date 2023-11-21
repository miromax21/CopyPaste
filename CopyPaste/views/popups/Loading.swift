//
//  Loading.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 02.08.2023.
//

import UIKit
import Combine
final class Loading: UIViewController, CustomPresentable {
  typealias T = BaseViewModel
  var viewModel: T!

  private var cancellables: Set<AnyCancellable> = []
  var customisation:  ((_ loading: Bool, _ connectionImage: UIImageView?, _ searchTitle: UILabel?, _ spinner: CustomSpinnerSimple?) -> Bool)?
  var completion: ((CustomPresentableCopletion) -> Void)?
  var refresh: (() -> Void)?
  var logOut: (() -> Void)?
  var transitionManager: UIViewControllerTransitioningDelegate?
  var loadingInprocess: Bool = false {
    didSet {
      loadingInprocess ? setLoading() : spinner?.stopAnimation()
    }
  }
  private var inited: Bool = false
  private lazy var spinner: CustomSpinnerSimple? = {
    let spinner = CustomSpinnerSimple(squareLength: 160)
    spinner.alpha = 0
    return spinner
  }()

  lazy var connectionImage: UIImageView! = {
    let connectionImage = UIImageView()
    connectionImage.tintColor = AppColors.primary.color
    return connectionImage
  }()

  private(set) lazy var searchTitle: UILabel? = {
    let title = UILabel()
    title.numberOfLines = 0
    title.text = ""
    return title
  }()

  private(set) lazy var searchPoints: UILabel? = {
    let points = UILabel()
    return points
  }()

  convenience init(image: UIImage?) {
    self.init()
    connectionImage.image = image
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setViews()
    setViewConstraints()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appMovedToForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )

  }

  @objc func appMovedToForeground() {
    setState()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if inited {
      return
    }
    addBlure()
    setState()
    inited = true
  }
  var cbSearching: AnyCancellable?
}

// MARK: - controll state
extension Loading {

  func setState(reloadCustomisation: Bool = false) {
    if loadingInprocess && !reloadCustomisation {
      return
    }
    loadingInprocess = true
    if let customisation = customisation {
      loadingInprocess = customisation(loadingInprocess, connectionImage, searchTitle, spinner)
    }
    animate()

    UIView.animate(withDuration: 0.8) { [weak self, loadingInprocess] in
      self?.spinner?.alpha = loadingInprocess ? 1 : 0
    }
  }

  private func addBlure() {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    view.insertSubview(blurEffectView, at: 0)
    blurEffectView.frame = view.frame
  }
}

// MARK: - render
private extension Loading {

  func setViews() {
    view.addSubview(spinner!)
    view.addSubview(searchTitle!)
    view.addSubview(connectionImage)
    view.addSubview(searchPoints!)

    connectionImage.translatesAutoresizingMaskIntoConstraints = false
    connectionImage.contentMode = .scaleAspectFill
    connectionImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
  }

  func setViewConstraints() {
    if let spinner = spinner {
      NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: connectionImage.centerXAnchor),
        connectionImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        connectionImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 3)
      ])
    }
    view.addConstraintsWithFormat(
      "V:[v0(100)]-60-[v1(300)]",
      options: .alignAllCenterX,
      views: connectionImage, searchTitle!
    )
  }

  func setLoading() {
    spinner?.startAnimation(delay: 0.015, replicates: 88)
    animate()
  }

  func animate() {
    if !loadingInprocess || (connectionImage.layer.animationKeys()?.contains("transform")) != nil {
      return
    }

    let animation = CABasicAnimation(keyPath: "transform")
    animation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.75, 0.75, 1))
    animation.duration = 1.3
    animation.autoreverses = true
    animation.repeatCount = .infinity
    connectionImage.layer.add(animation, forKey: "transform")
  }
}
