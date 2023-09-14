//
//  CalendarHelper.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 30.11.2022.
//

import Foundation
final class CalendarHelper {
  private var calendar = Calendar.current

  init() {
    calendar.timeZone = TimeZone.init(identifier: "ru_RU") ?? .current
  }

  func plusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: 1, to: date)!
  }

  func minusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: -1, to: date)!
  }

  func monthString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "LLLL"
    return dateFormatter.string(from: date)
  }

  func yearString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: date)
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

  func weekdaysFromLast(ofMonth month: Int, year: Int) -> Int {
    let comps = DateComponents(calendar: calendar, year: year, month: month)
    let date = calendar.date(from: comps)!
    let interval = Calendar.current.dateInterval(of: .month, for: date)
    let lastDays = (calendar.component(.weekday, from: interval!.end) - calendar.firstWeekday + 7) % 7
    return lastDays
  }
}
