//
//  LoginViewModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 11.10.2022.
//
import UIKit
enum RegistrationStatusEnum {
  case none, sending, failure, success
}
final class LoginViewModel: BaseViewModel {

  @Published var registrationStatus: RegistrationStatusEnum = .none
  @Published var qrCode: String = ""

  var reRegistration: Bool = false
  override init(coordinator: BaseCoordinator) {
    super.init(coordinator: coordinator)
  }

  func checkRegistration(code: String) {
    qrCode = code
    registrationStatus = .sending
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) { [weak self] in
      if code == "qqq" || code.isEmpty {
        self?.registrationStatus = .failure
        return
      }
      UserDataWrapper.shared.authData = AuthModel(result: 1, code: code)
      self?.registrationStatus = .success
    }
  }

  func showQrCodeView() {
    (coordinator as? RegistrationCoordinator)?.showCamera(completion: { [weak self] callBack in
      if let callBack = callBack as? String {
        UserDataWrapper.shared.authData = AuthModel(result: 1, code: callBack)
        self?.qrCode = callBack
        self?.checkRegistration(code: callBack)
       // self?.checkRegistration(code: callBack)
      }
    })
  }

  func goToMain() {
   // (coordinator as? RegistrationCoordinator)?.goToMain(nextPage: nil)
  }
}
