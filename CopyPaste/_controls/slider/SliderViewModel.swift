//
//  SliderViewModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
struct SliderViewModel {
  let nibName = "SlideView"
  var data    = [SliderModel]()
  var view: SlideView!

  init() {
    load()
  }

  mutating func load() {
    let path =
    Bundle.main.url(
      forResource: "\(String(describing: Locale.current.languageCode)).lproj/about)", withExtension: "json"
    ) ?? Bundle.main.url(forResource: "about", withExtension: "json")
    if let filePath = path {
      guard let data = try? Data(contentsOf: filePath) else { return }
      let jsonDecoder = JSONDecoder()
      if let data = try? jsonDecoder.decode([SliderModel].self, from: data) {
        self.data = data
      }
    }
  }

  func getSlides(owner: Any) -> [SlideView] {
    guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else { return []}
    return data.map {
      let slideView = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)?.first as? SlideView
      slideView?.configure(model: $0)
      return slideView
    }.compactMap{ $0 }
  }
}
