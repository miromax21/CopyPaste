//
//  VpnTunnelService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import NetworkExtension
import UIKit

class BaseVpnTunnelService: NSObject {
  var status: Dynamic<NEVPNStatus?>! = Dynamic(nil)
  var vpnStatus: NEVPNStatus? {
    willSet {
      if let next = newValue, [.connected, .disconnected, .invalid].contains(next) {
        status.value = newValue
      }
    }
  }
  var alert: UIAlertController?
  var userStop: Bool = false
}

final class VpnTunnelService: BaseVpnTunnelService {

  public static var shared = VpnTunnelService()

  private(set) var manager: NETunnelProviderManager?
  var initSuccess: Bool = false {
    didSet {
      if !initSuccess {
        manager = nil
      }
    }
  }
  override init() {
    super.init()
    initializeConnectionObserver()
  }

  final func initVpnTunnel(tryFirstStart: Bool) {
    NETunnelProviderManager.loadAllFromPreferences { [unowned self] (savedManagers: [NETunnelProviderManager]?, error: Error?) in
      guard error == nil else {
        vpnStatus = .invalid
        return
      }
      if let savedManager = savedManagers?.first {
        manager = savedManager
        reloadProfile()
        return
      }
      if tryFirstStart {
        vpnStatus = .invalid
        return
      }
      installProfile()
    }
  }

  final func reloadProfile() {
    manager?.loadFromPreferences(completionHandler: { [unowned self] _ in
      TunnelConfiguration().updateCurrent(manager: manager)
      manager?.saveToPreferences(completionHandler: { [weak self] error in
        guard error == nil else {
          self?.vpnStatus = .invalid
          return
        }
        self?.run()
      })
    })
  }

  final func hasPermissions(tryStart: Bool = false) -> Bool {
    // custom check
    return true
  }

  private final func run() {
    manager?.loadFromPreferences(completionHandler: { error in
      guard error == nil else {return}
      try? self.manager?.connection.startVPNTunnel()
    })
    userStop = false
  }

  private final func installProfile() {
    manager = TunnelConfiguration().makeDefaultTunnel()
    reloadProfile()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
extension NEVPNStatus {
  var isActive: Bool {
    switch self {
    case .connected: return true
    default: return false
    }
  }
}
