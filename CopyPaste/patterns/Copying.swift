//
//  Copying.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 22.08.2023.
//

import Foundation
protocol Copying {
  init(_ proto: Self)
}

extension Copying {
  public func copy() -> Self {
    return type(of: self).init(self)
  }
}
 
extension Array where Element: Copying {
  func deepCopy() -> [Element] {
    return map{ $0.copy() }
  }
}
