//
//  DynamicForFewModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

class DynamicForFew<T> {
  typealias Listener = ((T) -> Void)
  var listeners: [Listener?] = []
  var observers: [Int: Listener?] = [:]

  init(_ newValue: T) {
    value = newValue
  }

  func addObserver(_ observer: ObserverProtocol, completion: @escaping Listener) {
    self.observers[observer.id] = completion
  }

  func addBehaviorObserver(_ observer: ObserverProtocol, completion: @escaping Listener) {
    self.observers[observer.id] = completion
    completion(value)
  }

  func bindAndFire(_ listener: Listener?) {
    if let listener = listener {
      listeners.append(listener)
    }
    set(value: value)
  }

  var value: T {
    didSet {
      set(value: value)
    }
  }

  func unsubscribe(_ observer: ObserverProtocol) {
    self.observers.removeValue(forKey: observer.id)
  }

  private func set(value: T) {
    if !observers.isEmpty {
      for observer in observers {
        observer.value?(value)
      }
    }

    for listener in listeners {
      listener?(value)
    }
  }
}
protocol ObserverProtocol: AnyObject {}

extension ObserverProtocol {
  var id: Int {
    return unsafeBitCast(self, to: Int.self)
  }
}
