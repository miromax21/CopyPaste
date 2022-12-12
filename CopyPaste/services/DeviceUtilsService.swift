//
//  DeviceUtilsService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit
import CoreTelephony
import Network
import NetworkExtension

final class DeviceUtilsService {
  static var shared           = DeviceUtilsService()

  var vpnStatus: DynamicForFew<NEVPNStatus?> = DynamicForFew(VpnTunnelService.shared.status.value)
  var screenIsAvalable        = DynamicForFew(true)

  var internrtIsAvalable      = DynamicForFew(true)
  var locationIsAvalable      = DynamicForFew(false)
  var notificationsIsAvalable = DynamicForFew(false)

  var movedBackground = false
  var uiIsVisible: Bool {
    return !movedBackground && screenIsAvalable.value
  }

  lazy var carrierName: String = {
    getCarrierName()
  }()

  lazy var deviceName: String = {
    return getDeviceName()
  }()
  lazy var telephonyInfo: String = {
    return getTelephonyInfo()
  }()

  private var monitor: NWPathMonitor!

  private let networkInfo = CTTelephonyNetworkInfo()

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(isLockedState),
      name: UIApplication.protectedDataWillBecomeUnavailableNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(isLockedState),
      name: UIApplication.protectedDataDidBecomeAvailableNotification,
      object: nil
    )

    let queue = DispatchQueue(label: "miromax21.iternrtMonitor")
    monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { [weak self] path in
      let next = path.status != .unsatisfied
      if self?.internrtIsAvalable.value != next {
        self?.internrtIsAvalable.value = next
      }
    }
    monitor.start(queue: queue)
    bindServiceStatuses()
  }

  func toggleVpn(forcibly: Bool? = nil, trying: Bool = true) {
    VpnTunnelService.shared.toggleVpn(forcibly: forcibly, trying: trying)
  }

  func getTelephonyInfo() -> String {
    guard
      #available(iOS 12.0, *),
      let dict = networkInfo.serviceCurrentRadioAccessTechnology,
      let key = dict.keys.first,
      let carrierType = dict[key]
    else {
      guard #available(iOS 10.0, *) else {
        return networkInfo.currentRadioAccessTechnology ?? ""
      }
      return ""
    }
    return carrierType
  }

  func bindServiceStatuses() {
//    PushNotifications.shared.hasPermissions.bind { [weak self] hasAccess in
//      self?.notificationsIsAvalable.value = hasAccess
//    }

    LocationService.shared.hasAccess.bind({  [weak self] hasAccess in
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1300)) {
        self?.locationIsAvalable.value = hasAccess
      }
    })

    VpnTunnelService.shared.status.bind { [weak self] vpnStatus in
      guard let vpnStatus = vpnStatus else {
        return
      }
      self?.vpnStatus.value = vpnStatus
    }
  }

  @objc func isLockedState(notification: NSNotification) {
    var isLocked = true
    switch notification.name {
    case UIApplication.protectedDataWillBecomeUnavailableNotification : isLocked = true
    case UIApplication.protectedDataDidBecomeAvailableNotification: isLocked = false
    default: isLocked = true
    }
    screenIsAvalable.value = !isLocked
  }

  private func getCarrierName() -> String {
    guard
      let carriers = networkInfo.serviceSubscriberCellularProviders,
      let carrier1  = carriers["0000000100000001"],
      let carrierName = carrier1.carrierName
    else {
      return ""
    }
    return carrierName
  }

  private func getDeviceName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return mapToDevice(identifier: identifier)
  }
  // swiftlint:disable superfluous_disable_command trailing_newline
  // swiftlint:disable cyclomatic_complexity
  private func mapToDevice(identifier: String) -> String {
    return ""
  }
}
