//
//  extensions.Date.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
extension Date {

  func string(with format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }

  func fromString(_ forom: String, format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: forom)
  }

  var millisecondsSince1970: Int64 {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }

  func addMinute(_ minute: Int) -> Date? {
    var comps = DateComponents()
    comps.minute = minute
    let calendar = Calendar.current
    let result = calendar.date(byAdding: comps, to: self)
    return result ?? nil
  }

  func toLocalTime() -> Date {

    let timezoneOffset = TimeZone.current.secondsFromGMT()

    let epochDate = self.timeIntervalSince1970
    let timezoneEpochOffset = (epochDate + Double(timezoneOffset))

    return Date(timeIntervalSince1970: timezoneEpochOffset)
  }

  func daysInMonth(_ monthNumber: Int? = nil, _ year: Int? = nil) -> Int {
    var dateComponents = DateComponents()
    dateComponents.year = year ?? Calendar.current.component(.year, from: self)
    dateComponents.month = monthNumber ?? Calendar.current.component(.month, from: self)
    if
      let day = Calendar.current.date(from: dateComponents),
      let interval = Calendar.current.dateInterval(of: .month, for: day),
      let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
    { return days } else { return -1 }
  }
}
