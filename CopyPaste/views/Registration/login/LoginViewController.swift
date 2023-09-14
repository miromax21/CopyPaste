//
//  StatisticViewController.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 11.10.2022.
//

import UIKit
import Combine
import AudioToolbox
final class LoginViewController: UIViewController {
  private var cancellables: Set<AnyCancellable> = []
  var viewModel: LoginViewModel!
  let keyboardListener = KeyboardListener()
  var logoCenterConstraint: NSLayoutConstraint!
  var logoTopConstraint: NSLayoutConstraint!
  var logoContainer: UIView!
  var logoPositiomY: Double = 0.0
  var cancelTap: UITapGestureRecognizer!
  var keyboardSize: Double = 0
  var origilalHeight: CGFloat = 0

  lazy var loadSpiner: CustomSpinnerSimple = {
    let spinner = CustomSpinnerSimple(squareLength: 100)
    return spinner
  }()

  lazy var logo: UIImageView! = {
    let logoView = UIImageView(image: UIImage(named: "logo"))
    logoView.contentMode = .scaleAspectFit
    return logoView
  }()

  lazy var errrorView: UILabel = {
    let label = UILabel()
    label.alpha = 0
    label.text = "Неверно введен код"
    label.textColor = AppColors.white.color
    label.backgroundColor = AppColors.alertError.color
    return label
  }()

  lazy var loginTextField: TextField = {
    let settings = ControllSettings(colorType: .bordered, edgeInsets: 20)
    settings.cornerRadius = 20
    return ViewBuilder(settings: settings).makeTextField(placeholder: "Введите код", delegate: self)
  }()

  lazy var logInButton: CustomButton = {

    let iconSettings = SubviewSettings(margin: 15, width: 20, height: 20, view: loadSpiner, float: .right)
    var button = ViewBuilder(title: "Пролдолжить", style: .icon(iconSettings))
      .setColors(colorType: .filled)
      .makeButton()
    button.onClick = { [weak self] in
      self?.loadSpiner.startAnimation(delay: 0.04, replicates: 20)
      self?.viewModel.checkRegistration(code: self?.loginTextField.text ?? "")
      self?.logInButton.settings.subviews?.view?.alpha = 1
    }
    button.controlState = .disabled
    return button
  }()

  lazy var qrCodeButton: CustomButton = {
    var button = ViewBuilder(
      title: "Сканировать QR код",
      style: .text
    ) .makeButton()
    return button
  }()

  var dirtyField = false
  var code = ""
  private var showWarning = false
  private var keyboardDisplayed = false
  private var keyFrameHeight: CGFloat = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()
    addTargetsActions()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    view.frame.inset(by: UIEdgeInsets(top: .zero, left: 5.0, bottom: 150.0, right: .zero))
    view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 400, right: 8)

    initView()
    initBindings()
  }
  var show = true

  func initBindings() {

    viewModel.$qrCode.sink { [weak self] qrCode in
      guard let self = self else { return }
      self.loginTextField.text = qrCode
      self.dirtyField = false
      self.view.endEditing(true)
    }.store(in: &cancellables)

    viewModel.$registrationStatus.sink { [weak self] status in
      guard let self = self else { return }
      typealias RStatus = RegistrationStatusEnum
      if let success = [RStatus.success: true, RStatus.failure: false][status] {
        self.view.endEditing(true)
        self.setValidation(isValid: success)

        if success {
          self.loginTextField.delegate = nil
          self.startPresentation(show: false) {
            self.viewModel.goToMain()
          }
        } else {
          self.loadSpiner.stopAnimation()
          self.loginTextField.isUserInteractionEnabled = true
          self.logInButton.isEnabled = false
        }
      }
    }.store(in: &cancellables)

    qrCodeButton.onClick = { [weak self] in
      self?.viewModel.showQrCodeView()
    }
  }
  func setValidation(isValid: Bool) {
    setColors(error: !isValid)
    showWarning = !isValid
  }

   @objc func dismissKeyboard() {
     animateKeyboard(show: false)
     view.endEditing(true)
   }
}

extension LoginViewController {
  func initView() {
    view.backgroundColor = AppColors.backgroundMain.color
    addLoginFields()
    addlogo()
    startPresentation()
  }

  private func setColors(error: Bool = false) {
    logInButton.controlState = .disabled
    logInButton.settings.subviews?.view?.alpha = 1
    loginTextField.controlState = error ? .error : .active
    if dirtyField && error == showWarning {
      return
    }
  }

  private func addlogo() {
    view.addSubview(logo)
    logoCenterConstraint = logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    NSLayoutConstraint.activate([
      logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
      logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoCenterConstraint
    ])
    view.addConstraintsWithFormat("V:[v0(h)]", metrics: ["h": 45], views: logo)
  }

  private func addLoginFields() {
    let views: [UIView] =  [logInButton, qrCodeButton, errrorView, loginTextField]
    views.forEach {
      view.addSubview($0)
      let constraint = $0.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
      NSLayoutConstraint.activate([
        constraint,
        $0.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        $0.widthAnchor.constraint(lessThanOrEqualToConstant: 550)
      ])
      view.addConstraintsWithFormat("H:[v0]", options: .alignAllCenterX, views: $0)
    }

    view.addSubview(loginTextField)
    view.addConstraintsWithFormat("V:[v0(50)]-26-[v1(55)]",
                                  options: .alignAllLeft,
                                  views: loginTextField, qrCodeButton
    )
    view.addConstraintsWithFormat("V:[v0(45)]-40-|", views: logInButton)
    NSLayoutConstraint.activate([
      loginTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      errrorView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
    ])

  }

  func initPresentation(start: CGFloat) {
    qrCodeButton.alpha = start
    loginTextField.alpha = start
    logInButton.alpha = start
  }

  func startPresentation(show: Bool = true, completion: (() -> Void)? = nil) {

    initPresentation(start: show ? 0 : 1)
    if show {
      qrCodeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
      logInButton.transform = CGAffineTransform(translationX: 0, y: 10)
    }
    let animator = UIViewPropertyAnimator(duration: show ? 0.8 : 0.4, curve: .easeIn) { [self] in
      let toAlpha = show ? 1.0 : 0
      let deltaX: CGFloat = show ? 0 : -10
      logInButton.transform = CGAffineTransform(translationX: deltaX, y: 0)
      logInButton.alpha = toAlpha
      loginTextField.alpha = toAlpha
      qrCodeButton.alpha = toAlpha

      let sale = show ? 1 : 0.6
      loginTextField.transform = CGAffineTransform(scaleX: sale, y: sale)
      qrCodeButton.transform = CGAffineTransform(scaleX: sale, y: sale)
     }

    let animatorLogo = UIViewPropertyAnimator(duration: show ? 1.0 : 3, curve: .easeOut) { [self] in
      if show {
        logoCenterConstraint.isActive = false
        logoTopConstraint = logo.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100)
        logoTopConstraint.isActive = true
        UIView.animate(withDuration: 0.5) {  [self] in
          view.layoutIfNeeded()
        }
        logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // .translatedBy(x: 0, y: logoPositiomY)
        logo.alpha = 1
      } else {
        logo.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        logo.alpha = 0
      }
    }
    if let completion = completion {
      animatorLogo.addCompletion { position in
        if position == .end {
          completion()
        }
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
      animatorLogo.startAnimation()
      animator.startAnimation()
    })
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    keyboardListener.stopListeningToKeyboard()
  }
}

extension LoginViewController: UITextFieldDelegate {

  func textFieldDidEndEditing(_ textField: UITextField) {
    self.code = loginTextField.text ?? ""
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    setValidation(isValid: true)
    loginTextField.resignFirstResponder()
    return true
  }
  func textFieldDidBeginEditing(_ textField: UITextField) {
    setValidation(isValid: true)
  }
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    loginTextField.becomeFirstResponder()
    return true
  }
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    setValidation(isValid: true)
    return true
  }
}

private extension LoginViewController {
  func addTargetsActions() {
    cancelTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    cancelTap?.cancelsTouchesInView = false
    keyboardListener.startListeningToKeyboard()

    keyboardListener.$keyboardHeihgt.sink { [weak self] cgrect in
      guard let self = self else {return}
      let show = cgrect.height != 0

      if show {
        self.view.addGestureRecognizer(self.cancelTap)
        self.origilalHeight = self.view.frame.height
        self.keyboardSize = cgrect.height
      } else {
        self.view.removeGestureRecognizer(self.cancelTap)
      }
      self.animateKeyboard(show: show)
    }.store(in: &cancellables)
  }

  func animateKeyboard(show: Bool) {
    self.keyboardDisplayed = show
    let nextHeight = (show ? -1 : 1) * keyboardSize + CGFloat(Int(UIScreen.main.bounds.height))
    UIView.animate(withDuration: 0.1, delay: 0) { [self] in
      qrCodeButton.alpha = show ? 0 : 1
    }
    UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [self] in
      view.frame.size.height = show ? nextHeight: origilalHeight
      qrCodeButton.transform = CGAffineTransform(translationX: 0, y: show ? -50 : 0)
      view.layoutIfNeeded()
    }.startAnimation()
  }
}
