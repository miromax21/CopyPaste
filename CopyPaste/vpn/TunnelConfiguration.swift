//
//  TunnelConfiguration.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import NetworkExtension
enum VpnConfig: String {
  case serverAddress
  case serverPort
  case mtu
  case ip
  case subnet
  case dns
  case providerBundleIdentifier
  case localizedDescription
  var value: String {
    return self.rawValue
  }
}
struct TunnelConfiguration {

  func makeProvider() -> NETunnelProviderProtocol {
    let providerProtocol = NETunnelProviderProtocol()
    providerProtocol.providerBundleIdentifier = VpnConfig.providerBundleIdentifier.value
    providerProtocol.serverAddress = VpnConfig.serverAddress.value
    providerProtocol.providerConfiguration = [
      "dns": VpnConfig.dns.value,
      "ip": VpnConfig.ip.value,
      "mtu": VpnConfig.mtu.value,
      "port": VpnConfig.serverPort.value,
      "server": VpnConfig.serverAddress.value,
      "subnet": VpnConfig.subnet.value
    ]
    return providerProtocol
  }

  func makeDefaultTunnel() -> NETunnelProviderManager {
    let manager = NETunnelProviderManager()
    manager.protocolConfiguration   = NETunnelProviderProtocol()
    return manager
  }

  func updateCurrent(manager: NETunnelProviderManager?) {
    manager?.protocolConfiguration = makeProvider()
    manager?.localizedDescription  = VpnConfig.localizedDescription.value
    manager?.isEnabled             = true
  }

}
