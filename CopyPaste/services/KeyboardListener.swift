//
//  KeyboardListener.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 03.11.2022.
//

import UIKit
import Combine
public final class KeyboardListener {
  
  fileprivate(set) var keyboardFrame = CGRect.zero
  fileprivate var isListening = false
  
  @Published public var keyboardHeihgt: CGRect = .zero

  public init(){
    startListeningToKeyboard()
  }
  deinit {
    stopListeningToKeyboard()
  }
}

//MARK: - Notifications
extension KeyboardListener {
  
  var targetView: UIViewController? {
    (UIApplication.shared.connectedScenes.first!.delegate as? UIWindowSceneDelegate)?.window??.rootViewController
   // #available(iOS 13, *) else (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
  }
  
  public func startListeningToKeyboard() {
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
  
  public func stopListeningToKeyboard() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  fileprivate func keyboardWillShow(_ notification: Notification) {
    keyboardHeihgt = keyboardFrame(fromNotification: notification)
  }
  
  @objc
  fileprivate func keyboardWillHide(_ notification: Notification) {
    keyboardHeihgt = CGRect.zero
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
