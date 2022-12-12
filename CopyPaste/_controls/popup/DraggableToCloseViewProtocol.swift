//
//  DraggableToCloseViewProtocol.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
protocol DraggableToCloseView: AnyObject {
  var view: UIView! {get set}
  var pointOrigin: CGPoint? {get set}
  func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

extension DraggableToCloseView {
  func verticalSwipe(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    guard translation.y >= 0 else { return }
    view?.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
    if sender.state == .ended {
      let dragVelocity = sender.velocity(in: view)
      if dragVelocity.y >= self.view?.frame.height ?? 0 * 0.8 {
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view?.alpha = 0
        }
        self.dismiss(animated: true, completion: nil)
      } else {
        UIView.animate(withDuration: 0.3) {  [weak self] in
          self?.view?.frame.origin = self?.pointOrigin ?? CGPoint(x: 0, y: 400)
        }
      }
    }
  }
}
