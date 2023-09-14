//
//  extentions.Custom.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 28.12.2022.
//

import Foundation
extension Date {
  func getCurrentTimeStamp() -> Int {
    let secondsFromGmt = TimeZone.autoupdatingCurrent.secondsFromGMT()
    let timestamp  = Int(self.timeIntervalSince1970)
    return timestamp - secondsFromGmt
  }
}

extension URL {
  func appending(_ queryItems: [URLQueryItem]) -> URL? {
    guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
      return nil
    }
    urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
    return urlComponents.url
  }
}

extension NSRecursiveLock {
  @discardableResult
  func with<T>(_ block: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try block()
  }
}
