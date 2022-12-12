//
//  OpenLink.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//
/*
 @author: NEWBEDEV
 @link:  https://newbedev.com/when-can-i-use-a-sfsafariviewcontroller-wkwebview-or-uiwebview-with-universal-links
 */

import SafariServices

struct OpenLink {
  let view: UIViewController?
  func inAnyNativeWay(url: URL, dontPreferEmbeddedBrowser: Bool = false) {
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { (success) in
        if !success {
          if dontPreferEmbeddedBrowser {
            self.withRegularWay(url: url)
          } else {
            self.inAnyNativeBrowser(url: url)
          }
        }
      }
    } else {
      if dontPreferEmbeddedBrowser {
        withRegularWay(url: url)
      } else {
        inAnyNativeBrowser(url: url)
      }
    }
  }

  private func isItOkayToOpenUrlInSafariController(url: URL) -> Bool {
    return url.host != nil && (url.scheme == "http" || url.scheme == "https")
  }

  func inAnyNativeBrowser(url: URL) {
    if isItOkayToOpenUrlInSafariController(url: url) {
      inEmbeddedSafariController(url: url)
    } else {
      withRegularWay(url: url)
    }
  }

  func inEmbeddedSafariController(url: URL) { // EMBEDDED BROWSER ONLY
    let config = SFSafariViewController.Configuration()
    config.entersReaderIfAvailable = true
    let safaryView = SFSafariViewController(url: url, configuration: config)
    if #available(iOS 11.0, *) {
      safaryView.dismissButtonStyle = SFSafariViewController.DismissButtonStyle.close
    }
    view?.present(safaryView, animated: true)
  }

  func withRegularWay(url: URL) { // EXTERNAL BROWSER ONLY
    UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey(rawValue: "no"): "options"])
  }
}
