//
//  SceneDelegate.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 15.09.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var app: App!

  // swiftlint:disable:next line_length
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
  
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let nav = AppNavigationController()

    let appCoordinator = AppCoordinator(navigationController: nav)
    app = App(appCoordinator: appCoordinator)
    if let window = window {
      window.backgroundColor = AppColors.backgroundMain.color
      window.rootViewController = appCoordinator.navigationController
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {}

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {}
}
