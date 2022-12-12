//
//  LinkTextView.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
typealias HyperLinks = [String: String]
class LinkTextView: UITextView, UITextViewDelegate {

  typealias Links = [String: String]
  typealias OnLinkTap = (URL) -> Bool

  var onLinkTap: OnLinkTap?

  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    beLikeLabel()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    beLikeLabel()
  }

  func beLikeLabel() {
    isEditable = false
    isSelectable = true
    isScrollEnabled = false
    delegate = self
  }

  func addLinks(_ links: HyperLinks?) {
    guard
      let links = links,
      attributedText.length > 0
    else { return }
    let textAttibutes = NSMutableAttributedString(attributedString: attributedText)
    let types: NSTextCheckingResult.CheckingType = [.link]
    if (try? NSDataDetector(types: types.rawValue)) != nil {
      let range = NSRange(location: 0, length: attributedText.length)
      textAttibutes.removeAttribute(.link, range: range)
    }
    for (linkText, urlString) in links where linkText.count > 0 {
      let linkRange = textAttibutes.mutableString.range(of: linkText)
      textAttibutes.addAttribute(.link, value: urlString, range: linkRange)
    }

    linkTextAttributes = [
      .foregroundColor: AppColors.black.color,
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    attributedText = textAttibutes
  }

  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    return onLinkTap?(URL) ?? true
  }

  func textViewDidChangeSelection(_ textView: UITextView) {
    textView.selectedTextRange = nil
  }
}
