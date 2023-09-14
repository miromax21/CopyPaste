//
//  extension.Rsdfs.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 28.02.2023.
//

import UIKit
extension UICollectionReusableView {
  class var identifier: String {
    return String(describing: self)
  }
}

extension UITableViewCell {
  class var identifier: String {
    return String(describing: self)
  }
}
