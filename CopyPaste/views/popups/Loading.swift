//
//  Loading.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 02.08.2023.
//

import UIKit
final class Loading: UIViewController, CustomPresentable {
  var completion: ((Any?) -> Void)?
  var refresh: (() -> Void)?
  var logOut: (() -> Void)?
  var transitionManager: UIViewControllerTransitioningDelegate?
  
  var rejection: NetworkProvider.Rejection!
  private lazy var spinner: CustomSpinnerSimple? = {
    let spinner = CustomSpinnerSimple(squareLength: 160)
    spinner.alpha = 0
    return spinner
  }()
  
  private lazy var connectionImage: UIImageView! = {
    let connectionImage = UIImageView()
    connectionImage.tintColor = AppColors.primary.color
    return connectionImage
  }()
  
  private lazy var logOutButton: CustomButton = {
    let button = ViewBuilder(title: Loc(Loc.Global.btn_logOut), settings: ControllSettings(colorType: .text))
      .makeButton()
    button.onClick = { [weak self] in
      self?.spinner?.stopAnimation()
      UIView.animate(withDuration: 1.7, delay: 0.0, options: [.curveEaseInOut], animations: {
        self?.view.alpha = 0
      }, completion: { [weak self] _ in
        self?.dismiss(animated: false)
        self?.logOut?()
      })
    }
    return button
  }()
  
  convenience init (rejection:  NetworkProvider.Rejection =  NetworkProvider.Rejection(wifi: true, box: false, timeout: false)) {
    self.init()
    self.rejection = rejection
  }
  
  private lazy var refreshButton: CustomButton = {
    let button = ViewBuilder(title: Loc(Loc.Global.search))
      .makeButton()
    button.onClick = { [weak self] in
      self?.refresh?()
    }
    button.alpha = 0
    return button
  }()
  
  private lazy var searchTitle: UILabel? = {
    let title = UILabel()
    title.text = ""
    return title
  }()
  
  private lazy var searchPoints: UILabel? = {
    let points = UILabel()
    return points
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initView()
  }
  
  @objc func appMovedToForeground() {
    setState()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setState()
  }
  
}
extension Loading {
  private func initView(){
    view.addSubview(spinner!)
    view.addSubview(searchTitle!)
    view.addSubview(refreshButton)
    view.addSubview(connectionImage)
    view.addSubview(searchPoints!)
    view.addSubview(logOutButton)
    if let spinner = spinner {
      NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: connectionImage.centerXAnchor),
        spinner.centerYAnchor.constraint(equalTo: connectionImage.centerYAnchor),
        refreshButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        logOutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        connectionImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        connectionImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 3),
      ])
    }
    view.addConstraintsWithFormat(
      "V:[v0(100)]-60-[v1(40)]-(>=40)-[v2(45)]-10-[v3(40)]->=40-|",
      options: .alignAllCenterX,
      views: connectionImage, searchTitle!, refreshButton, logOutButton
    )
    connectionImage.translatesAutoresizingMaskIntoConstraints = false
    connectionImage.contentMode = .scaleAspectFill
    connectionImage?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
    connectionImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appMovedToForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    addBlure()
  }
  
  private func setLoading(){
    spinner?.startAnimation(delay: 0.015, replicates: 88)
    animate()
  }
  
  private func animate(){
    if !rejection.box {
      return
    }
    if ((connectionImage.layer.animationKeys()?.contains("transform")) != nil) {
      return
    }
    
    let animation = CABasicAnimation(keyPath: "transform")
    animation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.75, 0.75, 1))
    animation.duration = 1.3
    animation.autoreverses = true
    animation.repeatCount = .infinity
    connectionImage.layer.add(animation, forKey: "transform")
  }
  
  func setState(){
    let iconName = "antenna.radiowaves.left.and.right"
    
    if rejection.wifi {
      connectionImage?.image = UIImage(systemName: iconName + ".slash")
      searchTitle?.text =  Loc(Loc.Alert.wifi_not_available)
      spinner?.stopAnimation()
      logOutButton.isHidden = true
      return
    }
    let inProcess = !rejection.timeout
    
    connectionImage?.image = UIImage(systemName: iconName + (inProcess ?  "" : ".slash"))
    inProcess ? setLoading() : spinner?.stopAnimation()
    searchTitle?.text = inProcess ? Loc(Loc.Global.search_in_progress) : Loc(Loc.Global.search_not_found)
    animate()
    
    UIView.animate(withDuration: 0.8) { [weak self, inProcess] in
      self?.logOutButton.isHidden = false
      self?.refreshButton.alpha = inProcess ? 0 : 1
      self?.spinner?.alpha = inProcess ? 1 : 0
    }
  }
  
  private func addBlure(){
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = 0.3
    view.insertSubview(blurEffectView, at: 0)
    blurEffectView.frame = view.frame
  }
}
