//
//  Serialize.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import Foundation
protocol Serialasable: Codable {
  func serialize() -> [String: AnyObject]?
}
protocol DefaultSerialasable: Serialasable {}

extension DefaultSerialasable {
  func serialize() -> [String: AnyObject]? {

    let encoder = JSONEncoder()
    guard
      let data     = try? encoder.encode(self),
      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
    else {
      return nil
    }
    return jsonData
  }
}
