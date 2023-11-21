//
//  StatisticViewController.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 11.10.2022.
//

import UIKit
import Combine
import AudioToolbox
final class LoginViewController: UIViewController {
  private var cancellables: Set<AnyCancellable> = []
  internal var viewModel: LoginViewModel!
  private let keyboardListener = KeyboardListener()
  private var logoCenterConstraint: NSLayoutConstraint!
  private var logoTopConstraint: NSLayoutConstraint!
  private var logoContainer: UIView!
  private var logoPositiomY: Double = 0.0
  private var cancelTap: UITapGestureRecognizer!
  private var keyboardSize: Double = 0
  private var origilalHeight: CGFloat = 0

  private lazy var loadSpiner: CustomSpinnerSimple = {
    let spinner = CustomSpinnerSimple(squareLength: 100)
    return spinner
  }()

  private lazy var logo: UIImageView! = {
    let logoView = UIImageView(image: UIImage(named: "logo"))
    logoView.contentMode = .scaleAspectFit
    return logoView
  }()

  private lazy var errrorView: UILabel = {
    let label = UILabel()
    label.alpha = 0
    label.text = "Loc(Loc.Alert.wrong_code)"
    label.textColor = AppColors.white.color
    label.backgroundColor = AppColors.alertError.color
    return label
  }()

  private lazy var loginTextField: TextField = {
    let settings = ControllSettings(colorType: .bordered, edgeInsets: 20)
    settings.corner = .custom(20)
    let loginTextField = ViewBuilder(settings: settings).makeTextField(placeholder: "Loc(Loc.Global.enter_code)", delegate: self)
    loginTextField.returnKeyType = .send
    return loginTextField
  }()

  private lazy var logInButton: CustomButton = {
    var button = ViewBuilder(
      title: Loc(Loc.Global.btn_goOn),
      style: .icon(
        SubviewSettings(margin: 15, width: 20, height: 20, view: loadSpiner, float: .right)
      )
    )
    .setColors(colorType: .filled)
    .makeButton()

    button.onClick = { [weak self] in
      self?.loadSpiner.startAnimation(delay: 0.04, replicates: 20)
      self?.viewModel.checkRegistration(code: self?.loginTextField.text ?? "")
      self?.logInButton.settings.subviews?.view?.alpha = 1
    }
    return button
  }()

  private lazy var qrCodeButton: CustomButton = {
    var button = ViewBuilder(
      title: "(Loc(Loc.Global.to_scan_qr_code))",
      style: .text
    ) .makeButton()
    button.onClick = { [weak self] in
      self?.viewModel.showQrCodeView()
    }
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    addTargetsActions()
    setViews()
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    initBindings()
    origilalHeight = self.view.frame.height
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    keyboardListener.stopListeningToKeyboard()
  }

  @objc func dismissKeyboard() {
    animateKeyboard(show: false)
    view.endEditing(true)
  }
}

// MARK: - controll state
private extension LoginViewController {

  func showCode(code: String) {
    loginTextField.text = code
  }

  func displaylogInResult(success: Bool) {
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
  func initBindings() {
    viewModel.$state.sink { [weak self] state in
      switch state {
        case .none: break
        case .editing(let editing):
          self?.view.endEditing(editing)
        case .code(let code):
          self?.showCode(code: code)
        case .send: break
        case .result(let success):
          self?.displaylogInResult(success: success)
      }
    }.store(in: &cancellables)
  }

  func setValidation(isValid: Bool) {
    logInButton.settings.subviews?.view?.alpha = 1
    let state: ControllStates = isValid ? .active : .error
    logInButton.controlState = state
    loginTextField.controlState = state
  }

  func addTargetsActions() {
    cancelTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    cancelTap?.cancelsTouchesInView = false
    keyboardListener.startListeningToKeyboard()

    keyboardListener.$keyboardHeihgt.sink { [weak self] cgrect in
      guard let self = self else {return}
      let show = cgrect.height != 0

      if show {
        self.view.addGestureRecognizer(self.cancelTap)
        self.keyboardSize = cgrect.height
      } else {
        self.view.removeGestureRecognizer(self.cancelTap)
      }
      self.animateKeyboard(show: show)
    }.store(in: &cancellables)
  }

  func animateKeyboard(show: Bool) {
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

// MARK: - render
private extension LoginViewController {
  func setViews() {
    view.backgroundColor = AppColors.backgroundMain.color
    view.frame.inset(by: UIEdgeInsets(top: .zero, left: 5.0, bottom: 150.0, right: .zero))
    view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 400, right: 8)
    addLoginFields()
    addlogo()
    startPresentation()
  }

  func addlogo() {
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
    view.addConstraintsWithFormat(
      "V:[v0(50)]-26-[v1(55)]",
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
    func fade(alpha: Double) {
      logInButton.alpha = alpha
      loginTextField.alpha = alpha
      qrCodeButton.alpha = alpha
    }

    let animator = UIViewPropertyAnimator(duration: show ? 0.8 : 1.2, curve: .easeIn) { [self] in
      let deltaX: CGFloat = show ? 0 : -10
      logInButton.transform = CGAffineTransform(translationX: deltaX, y: 0)
      fade(alpha: show ? 1.0 : 0)
      let sale = show ? 1 : 0.85
      loginTextField.transform = CGAffineTransform(scaleX: sale, y: sale)
      qrCodeButton.transform = CGAffineTransform(scaleX: sale, y: sale)
    }

    let animatorLogo = UIViewPropertyAnimator(duration: show ? 1.0 : 3.5, curve: .easeOut) { [self] in
      if show {
        logoCenterConstraint.isActive = false
        logoTopConstraint = logo.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100)
        logoTopConstraint.isActive = true
        logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        logo.alpha = 1
      } else {
        logo.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        logo.alpha = 0.2
        logoTopConstraint.constant = 300
      }
      UIView.animate(withDuration: 0.5) {  [self] in
        view.layoutIfNeeded()
      }
    }
    if let completion = completion {
      animatorLogo.addCompletion { [weak self] position in
        fade(alpha: 0)
        if position == .end {
          self?.view.alpha = 0
          completion()
        }
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(show ? 1 : 0), execute: {
      animatorLogo.startAnimation()
      animator.startAnimation()
    })
  }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    viewModel.state = .send(textField.text ?? "")
    viewModel.state = .editing(false)
    return true
  }
  func textFieldDidBeginEditing(_ textField: UITextField) {
    setValidation(isValid: true)
  }
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    textField.becomeFirstResponder()
    setValidation(isValid: true)
    return true
  }
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    setValidation(isValid: true)
    return true
  }
}
