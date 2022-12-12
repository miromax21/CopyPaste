//
//  DynamicModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

class Dynamic<T> {
  typealias Listener = (T) -> Void
  var listener: Listener?

  func bind(_ listener: Listener?) {
    self.listener = listener
  }

  func bindAndFire(_ listener: Listener?) {
    self.listener = listener
    listener?(value)
  }

  var value: T {
    didSet {
      listener?(value)
    }
  }

  init(_ newValue: T) {
    value = newValue
  }
}
