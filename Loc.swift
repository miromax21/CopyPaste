//
//  extension.Custom.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.05.2023.
//

import Foundation
typealias Loc = String
protocol LocKey {
  var locKey: String {get}
}
// swiftlint:disable identifier_name
extension Loc {
  init(_ value: LocKey) {
    self = NSLocalizedString(value.locKey, comment: "")
  }
  enum Global: String, LocKey {
    case btn_goOn, btn_add, btn_save, btn_connect, btn_clear, btn_apply, btn_logOut,
         search, search_in_progress, search_not_found
    var locKey: String {
      return self.rawValue
    }
  }

  enum Alert: String, LocKey {
    case camera_message, camera_title, wifi_not_available
    var locKey: String {
      return "alert_\(self.rawValue)"
    }
  }

}
