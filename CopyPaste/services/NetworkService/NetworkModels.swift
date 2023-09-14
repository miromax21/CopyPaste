//
//  Nesad.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 02.12.2022.
//

import Foundation
enum NetworkServiceConfiguration: String {
  case type = "MyApp._tcp"
  case domain = "local."
  case queueLabel = "HostSocketQueue"
}

enum ConnectionResult: Equatable {
  case none
  case connecting
//  case state(connected: Bool)
  case success(message: Moc?)
  case failure
}

protocol NetworkServiceProtocol {
//  var connected: Bool {get}
  func tryConnect()
  func send(text: String)
}
