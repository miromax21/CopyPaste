//
//  VpnTunnelService.extension.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import NetworkExtension
import UIKit
protocol VpnProviderManager {
  func tryStart()
  func start()
  func stop()
  func toggle()
  func toggleVpn(forcibly: Bool?, trying: Bool?)
}

extension VpnTunnelService: VpnProviderManager {

  func tryStart() {
    if !hasPermissions(tryStart: true) {
      return
    }
    initVpnTunnel(tryFirstStart: true)
  }

  func toggleVpn(forcibly: Bool?, trying: Bool?) {
    if let forceRun = forcibly {
      if forcibly == (vpnStatus?.isActive ?? false) {
        return
      }
      if !forceRun {
        stop()
      } else {
        (trying ?? false) ? tryStart() : start()
      }
      return
    }
    toggle()
  }

  final func start() {
    if !hasPermissions(tryStart: false) {
      return
    }

    if !(status.value?.isActive ?? false) && manager != nil && initSuccess {
      reloadProfile()
      return
    }
    initSuccess = true
    initVpnTunnel(tryFirstStart: false)
  }

  final func stop() {
    userStop = true
    manager?.connection.stopVPNTunnel()
  }

  final func toggle() {
    let isActive = status.value?.isActive ?? false
    isActive ? stop() : tryStart()
  }

  final func initializeConnectionObserver () {
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.NEVPNStatusDidChange,
      object: nil,
      queue: nil
    ) { [unowned self] notification in
      guard
        let connection = notification.object as? NEVPNConnection,
        connection.manager.localizedDescription == VpnConfig.localizedDescription.value
      else { return }
      checkNEStatus(status: connection.status)
    }
  }

  private func checkNEStatus( status: NEVPNStatus) {
    if status == .disconnected {

    }

    if status == .invalid {
      initSuccess = false
    }
    vpnStatus = status
  }
}
