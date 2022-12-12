//
//  KeyboardListener.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 06.12.2022.
//

import UIKit

internal final class KeyboardListener {

  fileprivate(set) var keyboardFrame = CGRect.zero
  fileprivate var isListening = false

  var keyboardHeihgt: Dynamic<CGRect> = Dynamic(CGRect.zero)

  init() {
    startListeningToKeyboard()
  }

  deinit {
    stopListeningToKeyboard()
  }
}

// MARK: - Notifications
extension KeyboardListener {

  var targetView: UIViewController? {
    var window: UIWindow??
    if #available(iOS 13, *) {
      window = (UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate)?.window
    } else {
      window = (UIApplication.shared.delegate)?.window
    }
    return window??.rootViewController
  }

  func startListeningToKeyboard() {
    if isListening {
      return
    }

    isListening = true
    [
      UIResponder.keyboardWillShowNotification: #selector(keyboardWillShow),
      UIResponder.keyboardWillHideNotification: #selector(keyboardWillHide),
      UIApplication.willResignActiveNotification: #selector(appMovedToBackground)
    ].forEach {
      NotificationCenter.default.addObserver(self, selector: $0.value, name: $0.key, object: nil)
    }
  }

  func stopListeningToKeyboard() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc
  fileprivate func keyboardWillShow(_ notification: Notification) {
    keyboardHeihgt.value = keyboardFrame(fromNotification: notification)
  }

  @objc
  fileprivate func keyboardWillHide(_ notification: Notification) {
    keyboardHeihgt.value = CGRect.zero
  }

  @objc
  fileprivate func appMovedToBackground() {
    targetView?.view.endEditing(true)
  }

  fileprivate func keyboardFrame(fromNotification notification: Notification) -> CGRect {
    let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
    return value?.cgRectValue ?? CGRect.zero
  }
}
