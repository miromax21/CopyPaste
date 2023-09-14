//
//  TvBoxMessageSender.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 18.10.2022.
//

import Foundation
struct Moc: EncodableJson, Decodable, Equatable {
  enum ClientMessageType: String, Encodable {
    case connected
    case state
  }
}
final class MessageSender {
  let messageTag = 1434
  let nameTag = 4
  var sender: String = "client63"
  var receiver: String = ""
  let id: Int64 = 1

  func update(target: String, type: Moc.ClientMessageType) -> EncodableJson {
    return Moc()
  }

  func connected() -> EncodableJson {
    return Moc()
  }

  func getMessage(from: SenderTypeEnum) -> EncodableJson {
    switch from {
      case .state(let target, let type): return update(target: target, type: type)
      case .connected: return connected()
    }
  }
}

enum SenderTypeEnum {
  case state(String, for: Moc.ClientMessageType)
  case connected
}
