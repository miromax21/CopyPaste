//
//  Animator.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
  private var hasAnimatedAllCells = false
  private let animation: Animation

  init(animation: @escaping Animation) {
    self.animation = animation
  }

  func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
    guard !hasAnimatedAllCells else {
      return
    }

    animation(cell, indexPath, tableView)
    hasAnimatedAllCells = false
  }

  static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
    return { cell, indexPath, _ in
      cell.transform = CGAffineTransform(translationX: 0, y: -10)
      cell.alpha = 0

      UIView.animate(
        withDuration: duration,
        delay: delayFactor + Double(indexPath.row) / 13,
        animations: {
          cell.transform = CGAffineTransform(translationX: 0, y: 10)
          cell.alpha = 1
        })
    }
  }
}
