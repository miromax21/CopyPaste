//
//  UserDataWrapper.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 18.10.2022.
//

import Foundation

final class UserDataWrapper {
  enum Keys: String {
    case authData, uuid, notifications, appServerVersion
  }
  static let shared = UserDataWrapper()
  let sharedUserMemory = UserDefaults.standard //(suiteName: ConstantsEnum.userDefaultsSuiteName.rawValue)
  var authData: AuthModel? {
    get {
      guard
        let data = sharedUserMemory.string(forKey: Keys.authData.rawValue)?.data(using: .utf8),
        let authData = try? JSONDecoder().decode(AuthModel.self, from: data)
      else {
        return nil
      }
      return authData
    }
    set {
      guard let jsonString = newValue?.asString  else {
        return
      }
      sharedUserMemory.set(jsonString, forKey: Keys.authData.rawValue)
    }
  }

  func logOut() {
    sharedUserMemory.set("", forKey: Keys.authData.rawValue)
  }

}
