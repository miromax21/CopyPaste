//
//  CalendarHelper.swift
//  CopyPaste
//
//  Created by Sergey Zhidkov on 06.12.2022.
//

import Foundation
class CalendarHelper {
  let calendar = Calendar.current

  func plusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: 1, to: date)!
  }

  func minusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: -1, to: date)!
  }

  func monthString(date: Date) -> String {
    return string(date: date, with: "LLLL")
  }

  func yearString(date: Date) -> String {
    return string(date: date, with: "yyyy")
  }

  func daysInMonth(date: Date) -> Int {
    let range = calendar.range(of: .day, in: .month, for: date)!
    return range.count
  }

  func dayOfMonth(date: Date) -> Int {
    let components = calendar.dateComponents([.day], from: date)
    return components.day!
  }

  func firstOfMonth(date: Date) -> Date {
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
  }

  func weekDay(date: Date) -> Int {
    let components = calendar.dateComponents([.weekday], from: date)
    return components.weekday! - 1
  }

  func weekdayNameFromWeekdayNumber(weekdayNumber: Int) -> String {
    let weekdaySymbols = calendar.shortWeekdaySymbols
    let index = (weekdayNumber + calendar.firstWeekday - 1) % 7
    return weekdaySymbols[index]
  }

  private func string(date: Date, with format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
}
