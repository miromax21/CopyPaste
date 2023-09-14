//
//  cb.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.09.2023.
//

import Foundation
import CoreLocation
import CoreBluetooth
final class CBUserObserver: NSObject, CBCentralManagerDelegate {
  var manager : CBCentralManager!
  var locationService: LocationBecons!
  var needUpdate: Bool = true
  var cbIsAvalable: Bool = false {
    didSet {
      needUpdate = cbIsAvalable != oldValue
      cbIsAvalable ? locationService.startScanningCLBeacon() : locationService.stopScanningCLBeacon()
    }
  }
  @Published  var responderBeacon: CLBeacon?
  
  init(locationService: LocationBecons) {
    super.init()
    self.locationService = locationService
    self.locationService.findBeacons = { [weak self] (beacons: [CLBeacon]) in
      guard
        let self = self,
        beacons.count > 0,
        let beacon = beacons.sorted(by: {$0.rssi > $1.rssi}).first
      else { return }
      self.responderBeacon = beacon
    }
    initialize()
    locationService.start()
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
      case .poweredOff: cbIsAvalable = false
      case .poweredOn: cbIsAvalable = true
      default: break
    }
  }
  
  private func initialize() {
    manager = CBCentralManager(delegate: self, queue: nil)
  }
}

