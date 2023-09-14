//
//  LocationService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import CoreLocation
import UIKit
class LocationService: NSObject {

  static var shared = LocationService()
  var alertTimer: Timer?
  var tryToStart: Bool = false
  var alert: UIAlertController?
  var hasAccess = Dynamic(false)
  var showNotification: Bool = false

  private let locationManager = CLLocationManager()
  private var authStatusPreeviouse: CLAuthorizationStatus?
  var pendingSetting: Bool = false
  var authStatus: CLAuthorizationStatus {
    if #available(iOS 14, *) {
      return locationManager.authorizationStatus
    } else {
      return CLLocationManager.authorizationStatus()
    }
  }
  var location: CLLocation? {
    return locationManager.location
  }

  override init() {
    super.init()
    showNotification = true // Check if foreground
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillEnterForeground(notification:)),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
  }
  func tryStart() {
    tryToStart = true
    showNotification = false
    becomeResponder()
  }

  func start() {
    tryToStart = false
    showNotification = true
    becomeResponder()
  }
}

extension LocationService: CLLocationManagerDelegate {

  func getAlert() -> UIAlertController? {
    if !hasAccess.value, showNotification && !tryToStart {
      let bundleId = Bundle.main.bundleIdentifier == "" ? "/\(String(describing: Bundle.main.bundleIdentifier))" : ""
      let url = !CLLocationManager.locationServicesEnabled()
        ? URL(string: "App-prefs:Privacy&path=LOCATION")!
        : URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION\(bundleId)&path=LOCATION")
      return buildAlert(url: url!, global: !CLLocationManager.locationServicesEnabled())
    }
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    hasAccess.value = status == .authorizedAlways
    checkPermissions(nextStatus: status)
  }

  private func setupLocationManager() {
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.distanceFilter = 30
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.activityType = .automotiveNavigation
  }

  private func becomeResponder() {
    DispatchQueue.main.async { [unowned self] in
      pendingSetting = true
      locationManager.delegate = self
      setupLocationManager()
      checkPermissions()
    }
  }

  private func checkPermissions(nextStatus: CLAuthorizationStatus? = nil ) {
    pendingSetting = true
    let status = nextStatus ?? authStatus

    if status == .denied {
      authStatusPreeviouse = authStatus
      if tryToStart {
        hasAccess.value = false
        return
      }
      DispatchQueue.main.async { [weak self] in
        self?.setAccess(has: false)
      }
      return
    }
    if [.authorizedAlways].contains(status) {
      locationManager.requestAlwaysAuthorization()
      pendingSetting = false
      setAccess(has: true)
    }

    if [.authorizedWhenInUse].contains(status) {
      locationManager.requestAlwaysAuthorization()
      pendingSetting = false
      setAccess(has: false)
    }

    if status == .notDetermined || authStatus == .restricted {
      alertTimer?.invalidate()
      alertTimer = nil
      locationManager.requestAlwaysAuthorization()
      showNotification = false
      setAccess(has: false)
    }
    authStatusPreeviouse = authStatus

  }

  private func buildAlert(url: URL, global: Bool = false) -> UIAlertController {
    let alert = UIAlertController(
      title: NSLocalizedString("geo_permissions_title", comment: ""),
      message: global
        ? NSLocalizedString("geo_turn_on", comment: "")
        : NSLocalizedString("geo_turn_on_to_always", comment: ""),
      preferredStyle: .actionSheet
    )
    [
      UIAlertAction(title: NSLocalizedString("go_to_settings", comment: ""), style: .default) { [weak self] _ in
        DispatchQueue.main.async { [weak self] in
          self?.alert?.dismiss(animated: false)
        }
        self?.alert = nil
        UIApplication.shared.open(url)
      }
    ].forEach {
      alert.addAction($0)
    }
    return alert
  }

  @objc private func initGeoHandler() {
    setupLocationManager()
    becomeResponder()
  }

  @objc private func applicationWillEnterForeground(notification: NSNotification) {
    if pendingSetting == false {
      return
    }
    pendingSetting = false
    checkPermissions()
  }

  private func setAccess(has: Bool) {
    authStatusPreeviouse = authStatus
    if has || [.authorizedAlways, .authorizedWhenInUse].contains(authStatus) {
      pendingSetting = false
      hasAccess.value = true
    }
    if tryToStart {
      hasAccess.value = false
    }
    hasAccess.value = has
  }

  @objc private func cancelTimer(notification: NSNotification) {
    alertTimer?.invalidate()
    alertTimer = nil
    setAccess(has: false)
  }
}


final class LocationBecons: LocationService {
  
  var findBeacons: (([CLBeacon])-> ())?
  
  private let locationManager = CLLocationManager()
    func startScanningCLBeacon() {
      let beacons = getCLBeaconConstraints()
      beacons.forEach{
        self.locationManager.startRangingBeacons(satisfying: $0)
      }
    }
    
    func stopScanningCLBeacon(){
      let beacons = getCLBeaconConstraints()
      beacons.forEach{
        self.locationManager.stopRangingBeacons(satisfying: $0)
      }
    }
    
    private func getCLBeaconConstraints() -> [CLBeaconIdentityConstraint] {
      let ids: [String] = ["2F234454-CF6D-4A0F-ADF2-F4911BA9FFA0"]
      return ids.compactMap {
        if let uid = UUID(uuidString: $0){
          return CLBeaconIdentityConstraint(uuid: uid)
        }
        return nil
      }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
      if beacons.count > 0 {
        findBeacons?(beacons)
      } else {
        print(" not found")
      }
    }
}
