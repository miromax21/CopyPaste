//
//  Application.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import Foundation
import Combine
typealias StartFrom = ((_ coordinator: AppCoordinatorEnum) -> Void)
final class App {

  var start: StartFrom!
  weak var appNavigation: AppNavigationController!

  var userData: AuthModel? {
    return ServiceStore.shared.defaults[.authData]
  }

  var needAuthorization: Bool {
    get { userData == nil}
    set { logOut() }
  }
  var cbobserver: CBUserObserver!
  init(appCoordinator: AppCoordinator) {
  //  connectionProvider = NetworkProvider()
    self.appNavigation = appCoordinator.navigationController

    appCoordinator.app = self
    start = appCoordinator.start
    start(needAuthorization ? .auth : .main(present: nil))
  }

  private func logOut() {
    ServiceStore.shared.defaults.authData = nil
    start(.auth)
    ServiceStore.shared.network.reset()
  }
}
