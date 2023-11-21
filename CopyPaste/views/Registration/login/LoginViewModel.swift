//
//  LoginViewModel.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 11.10.2022.
//
import UIKit
import Combine
enum RegistrationState {
  case none, editing(Bool), code(String), send(String), result(Bool)
}
final class LoginViewModel: BaseViewModel {
  private var cancellables: Set<AnyCancellable> = []
  @Published var state: RegistrationState = .none
  var provider = Provider<CompanionAppTargetType>()
  var reRegistration: Bool = false
  override init(coordinator: BaseCoordinator) {
    super.init(coordinator: coordinator)
    subscribe()
  }
}

// MARK: - state
internal extension LoginViewModel {

  private func subscribe() {
    $state.sink { [weak self] state in
      if case .send(let code) = state {
        guard let self = self,
              code != ""
        else { return }
        self.checkRegistration(code: code)
      }
    }.store(in: &cancellables)
  }

  func checkRegistration(code: String) {
    state = .editing(false)
    state = .code(code)
    provider.request(.auth(.code(code)), castAs: AuthModel.self)
      .sink(
       receiveCompletion: { [weak self] result in
         switch result {
           case .failure: self?.state = .result(false)
           case .finished: self?.state = .result(true)
         }
       },
       receiveValue: { [weak self] model in
       //  self?.serviceStore?.setAppCode(code: code, authData: model.value)
      }).store(in: &cancellables)
  }

  func showQrCodeView() {
    (coordinator as? RegistrationCoordinator)?.showCamera(completion: { [weak self] callBack in
//      if case .emit(let code) = callBack, let qrCode = code as? String {
//        self?.checkRegistration(code: qrCode)
//      }
    })
  }

  func goToMain() {
//    (coordinator as? RegistrationCoordinator)?.goToMain(nextPage: nil)
  }
}

