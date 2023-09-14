//
//  RingBuffer.swift
//  CopyPaste
//
//  Created by Maksim Mironovon 28.12.2022.
//

import Foundation

public struct RingBuffer<T> {

  public typealias BufferTarget = (item: T?, at: Int)

  fileprivate var readIndex = 0
  fileprivate var writeIndex = 0
  fileprivate let arraySize: Int!
  fileprivate var array: [T?]

  public var state: [T] {
    return array.compactMap { $0 }
  }

  public init(count: Int) {
    array = [T?](repeating: nil, count: count)
    arraySize = count
  }

  public mutating func write(_ element: T) {
    array[writeIndex % array.count] = element
    increment(target: &writeIndex)
  }

  public mutating func clear(atIndex: Int) {
    array[atIndex] = nil
    increment(target: &readIndex)
  }

  public mutating func read() -> BufferTarget? {
    if !isEmpty {
      let nextIndex = readIndex % array.count
      let element = array[nextIndex]
      return (item: element, at: nextIndex)
    } else {
      return nil
    }
  }

  fileprivate func increment(target: inout Int) {
    target = (target + 1) % arraySize
  }

  fileprivate var availableSpaceForReading: Int {
    return writeIndex - readIndex
  }

  public var isEmpty: Bool {
    return availableSpaceForReading == 0
  }

  fileprivate var availableSpaceForWriting: Int {
    return arraySize - availableSpaceForReading
  }

  public var isFull: Bool {
    return availableSpaceForWriting == 0
  }
}
