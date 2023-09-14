//
//  CalendarDay.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 10.03.2023.
//

import UIKit

struct CalendarDay: Hashable {
  let day: Int
  let value: Int?
  var indication: ValueIndication {
    return ValueIndication(value: value)
  }

  enum ValueIndication {
    case none, bad, good, nice, greate
    init(value: Int?) {
      guard let value = value else {
        self = .none
        return
      }
      switch value {
      case _ where value < 0: self = .none
      case _ where value < 10: self = .bad
      case _ where value < 20: self = .good
      case _ where value > 20: self = .nice
      default: self = .none
      }
    }
    var color: AppColors {
      var color: AppColors
      switch self {
      case .none: color = .backgroundMain
      case .bad: color = .alertError
      case .good: color = .primary
      case .nice: color = .alertWarning
      case .greate: color = .alertInfo
      }
      return color
    }
  }
}

struct CashedStatistic: EncodableJson, Codable {
  var statistic: [Statistic] = []
}
struct Statistic: Hashable, Codable {
  var activity: Int = 0
  var dateString: String = ""
  var date: Date? {
    return  Date().fromString(dateString, format: "dd-MM-yyyy")
  }
}
