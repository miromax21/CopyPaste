//
//  extension.UserDefaults.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.09.2023.
//

import Foundation
typealias CopyPsasteUserDefaults = UserDefaults
extension CopyPsasteUserDefaults {
  enum Keys: String {
    case authData, lastStatisticUpdate, statisticCache
  }
//  static var shared = CompanipnAppUserDefaults()
  subscript<T: EncodableJson & Codable>(key: Keys) -> T? {
    get {
      guard
        let data = self[key]?.data(using: .utf8),
        let authData = try? JSONDecoder().decode(T.self, from: data)
      else { return nil}
      return authData
    }
    set { self[key] = newValue?.asString }
  }
  subscript(key: Keys) -> String? {
    get {
      return self.string(forKey: key.rawValue)
    }
    set{
      self.set(newValue, forKey: key.rawValue)
    }
  }
  
  var authData: AuthModel? {
    get { return self[.authData]}
    set { self[.authData] = newValue?.asString}
  }
  
}
