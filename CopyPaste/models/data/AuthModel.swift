//
//  AuthModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 18.10.2022.
//

import Foundation
struct AuthModel: EncodableJson, Codable {
  var success: Bool {
    return result == 0
  }
  var result: Int = -1
  var code: String = ""
  var deviceOwner: String?
}
protocol EncodableJson: Encodable {
  var asString: String? { get }
}

extension EncodableJson {
  var asString: String? {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .withoutEscapingSlashes
    
    do {
      let jsonData = try jsonEncoder.encode(self)
      return String(data: jsonData, encoding: .utf8)
    } catch { return nil }
  }
}
