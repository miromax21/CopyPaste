//
//  NetworkService.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 15.09.2022.
//

import Foundation
//import CocoaAsyncSocket
import Combine
fileprivate var MaxTryCount = 10
final class NetworkService: NSObject, NetworkServiceProtocol {

  @Published var state: ConnectionResult = .none
  private(set) var connected: Bool = false
  var inProcess: Bool {
    switch state {
      case .success(_), .connecting: return true
      default: return false
    }
  }

  private var netService: NetService?
  private var netServiceBrowser: NetServiceBrowser?
  private var serverAddresses: [Data]?
  private let socketQueue = DispatchQueue(label: NetworkServiceConfiguration.queueLabel.rawValue, attributes: .concurrent)
  private var socket: Any? //GCDAsyncSocket?
  private var messageSender: MessageSender!

  init(messageSender: MessageSender) {
    super.init()
    self.messageSender = messageSender
    netServiceBrowser = NetServiceBrowser()
    
    netServiceBrowser?.delegate = self
    netServiceBrowser?.searchForServices(
      ofType: NetworkServiceConfiguration.type.rawValue,
      inDomain: NetworkServiceConfiguration.domain.rawValue)
    initConnection()
  }
  func initConnection() {
    netServiceBrowser?.schedule(in: .current, forMode: .default)
    netService?.startMonitoring()
    
  }

  private func reset() {
    netServiceBrowser?.remove(from: RunLoop.current, forMode: .default)
    netServiceBrowser?.stop()
    connected = false
  }
  func mock() {
  //  self.state = .success(message: getMoc())
  }

  func tryConnect() {
    state = .connecting
    netServiceBrowser?.schedule(in: .current, forMode: .default)
    netService?.startMonitoring()
    connectToNextAddress()
  }

  func send(text: String) {
    guard var data = text.data(using: .utf8) else {
      state = .failure
      return
    }
   // data.append(GCDAsyncSocket.crlfData())
 //   socket?.write(data, withTimeout: 2, tag: messageSender.messageTag)
  }

  func connectToNextAddress() {
//    state = .connecting
//    var searchDone = false
//    while !searchDone && serverAddresses?.count ?? 0 > 0 {
//      if let addr = serverAddresses?.remove(at: 0) {
//        do {
//          try socket?.connect(toAddress: addr)
//          searchDone = true
//        } catch {
//          state = .failure
//        }
//      }
//    }
//    if connected || searchDone{
//      return
//    }
//    self.UpdateState(with: nil)
  }
  
  func connectionRefused(){
    reset()
  }

}

extension NetworkService: NetServiceBrowserDelegate {
  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
    state = .failure
  }

  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    if netService == nil {
      netService = service
      netService?.delegate = self
      netService?.resolve(withTimeout: 5)
    }
  }

  func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
    state = .failure
  }
}

extension NetworkService: NetServiceDelegate {
  func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
    state = .failure
  }

  func netServiceDidResolveAddress(_ sender: NetService) {
    if serverAddresses == nil {
      serverAddresses = sender.addresses
    }
    if socket == nil {
     // socket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
      connectToNextAddress()
    }
    if state == .none {
      tryConnect()
    }
  }
}

//extension NetworkService: GCDAsyncSocketDelegate {
//  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
//    newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: messageSender.messageTag)
//  }
//
//  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
//    socket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: messageSender.nameTag)
//    connected = true
//    let message = messageSender.connected().asString!.replacingOccurrences(of: ",\"receiver\":\"\"", with: "")
//    send(text: message)
//  }
//
//  func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//    connected = false
//
//  }
//  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//    sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: messageSender.messageTag)
//    UpdateState(with: data)
//  }
//
//  private func UpdateState(with data: Data?) {
//    let decoder = JSONDecoder()
//    guard
//      let data = data,
//      let message: Moc = try? decoder.decode(Moc.self, from: data)
//    else {
//      return
//    }
//    messageSender.receiver = message.sender
//    self.state = .success(message: message)
//  }
//}
