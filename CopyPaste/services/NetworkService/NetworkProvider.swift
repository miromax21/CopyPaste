//
//  sdf.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
//

import Foundation
import Combine
import Network
final class NetworkProvider {
  struct Rejection: Hashable {
    var wifi, box, timeout: Bool
  }
  enum StateEnum: Equatable {
    case none
    case connecting
    case success(state: [String])
    case failure(Rejection)
  }
  private(set) var foundWiFi: Bool = false
  private lazy var monitor: NWPathMonitor = {
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    monitor.pathUpdateHandler = { [weak self] path in
      if path.status == .unsatisfied {
        self?.service.connectionRefused()
        return
      }
      self?.wifiFounded(foundWiFi: path.status != .unsatisfied)

    }
    return monitor
  }()
  
  private var tryCount = 0
  private let messageService = MessageSender()
  private var _service: NetworkService!
  private var service: NetworkService! {
    if _service == nil {
      _service = NetworkService(messageSender: messageService)
    }
    return _service
  }
  var cancellables: Set<AnyCancellable> = []
  
  var connected: Bool {
    return service?.connected ?? false
  }
  
  @Published var state: StateEnum = .none
  
  init() {
    bindState()
    let queue = DispatchQueue(label: "copyPaste.iternrtMonitor")
    monitor.start(queue: queue)
  }
  
  func bindState() {
    service.$state
      .receive(on: DispatchQueue.global(qos: .background))
      .sink { [weak self] state in
        guard let self = self else { return }
        let wifi = self.foundWiFi
        switch state {
          case .success(let message):
            self.state = .success(state:  [])
          case .failure:
            self.state = .failure(Rejection(wifi: wifi, box: false, timeout: false))
          case .connecting:
            self.state = .connecting
          default: break;
        }
      }.store(in: &cancellables)
  }
  
  func reset() {
    _service = nil
  }
  
  func tryConnect() {
    if service.inProcess {
      return
    }
    if (service.connected) {
      send(.connected)
      tryCount = 0
      return
    }
    tryCount += 1
    bindState()
    service.tryConnect()
  }
  
  func send(_ next: SenderTypeEnum) {
    DispatchQueue.global(qos: .background).async { [unowned self] in
      let message = messageService.getMessage(from: next)
      let jsonEncoder = JSONEncoder()
      if let jsonData = try? jsonEncoder.encode(message), let message = String(data: jsonData, encoding: .utf8) {
        service.send(text: message)
      }
    }
  }
  
  func wifiFounded(foundWiFi: Bool){
    self.foundWiFi = foundWiFi
    if !foundWiFi {
      service.connectionRefused()
    } else {
      tryConnect()
    }
  }
}
