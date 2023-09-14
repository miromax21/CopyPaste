//
//  Faq.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 28.02.2023.
//

import Foundation

struct FaqProjectModel {
  var data = [FaqSection]()
  init() {
    load()
  }
  mutating func load() {
    if let filePath = Bundle.main.url(forResource: "faq", withExtension: "json") {
      guard let data = try? Data(contentsOf: filePath) else { return }
      let jsonDecoder = JSONDecoder()
      self.data = (try? jsonDecoder.decode([FaqSection].self, from: data)) ?? []
    }
  }
}

struct FaqSection: Codable {
  var title: String
  var items: [FaqItem]

  enum CodingKeys: String, CodingKey {
    case title, items
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = (try? container.decode(String.self, forKey: CodingKeys.title)) ?? ""
    self.items = (try? container.decode([FaqItem].self, forKey: CodingKeys.items)) ?? []
  }
}

struct FaqItem: Codable {
  var type: String
  var value: String
  var options: [String: String]?

  enum CodingKeys: String, CodingKey {
    case type, value, options
  }
  enum OptionKeys: String {
    case ratio, darkValue
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.type       = (try? container.decode(String.self, forKey: CodingKeys.type)) ?? ""
    self.value      = (try? container.decode(String.self, forKey: CodingKeys.value)) ?? ""
    self.options    = (try? container.decode([String: String].self, forKey: CodingKeys.options)) ?? [:]
  }
}
