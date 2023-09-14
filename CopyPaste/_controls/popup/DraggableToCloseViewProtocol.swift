//
//  DraggableToCloseViewProtocol.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 29.09.2022.
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

  func addSwipeControl(into: UIView) -> UIView {
    let closeSwipeView: UIView = {
      let view = UIView()
      let swipeView = UIView()
      swipeView.backgroundColor = AppColors.black.color(alpha: 36)
   //   swipeView.alpha = 0.6
      swipeView.layer.cornerRadius = 2.5
      view.addSubview(swipeView)
      view.addConstraintsWithFormat("H:[v0(134)]", views: swipeView)
      view.addConstraintsWithFormat("V:|-5-[v0(5)]", views: swipeView)
      swipeView.layer.cornerRadius = 2
      swipeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      return view
    }()
    into.addSubview(closeSwipeView)
    into.addConstraintsWithFormat("V:[v0(40)]", views: closeSwipeView)
    into.addConstraintsWithFormat("H:[v0(60)]", views: closeSwipeView)
    closeSwipeView.centerXAnchor.constraint(equalTo: into.centerXAnchor).isActive = true
    return closeSwipeView
  }
}
