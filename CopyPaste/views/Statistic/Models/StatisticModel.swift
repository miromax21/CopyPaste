//
//  StatisticModel.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 21.04.2023.
//

import Foundation
typealias ModelEnum = CalendarSectionConfigurator.SectionLayoutEnum
final class StatisticModel {
  var items: [ModelEnum] = []
  var dateModel: StatisticPickerModel!
  var lastUpdate: String?
  var statisticsMmonths: [(key: String, value: [Int: [Statistic]])] = []
  var statisticSnapshot: [String: CalendarSectionConfigurator.Snapshot] = [:]
  var isEmpty: Bool = false
  func getSnapshot() ->  CalendarSectionConfigurator.Snapshot {
    let items = fetchData(mode: .calendar(nil))
    var snapshot = CalendarSectionConfigurator.Snapshot()
    snapshot.appendSections(["statistic"])
    snapshot.appendItems(items)
    return snapshot
  }
  init(defaults: CopyPsasteUserDefaults) {

    dateModel = StatisticPickerModel()
    lastUpdate = defaults[.lastStatisticUpdate]
    tryFetchFromCache(defaults: defaults)
  }
}

extension StatisticModel {
  func fetchData( mode: ModelEnum? = .calendar(nil)) -> [ModelEnum] {
    var stringDate = ""
    var days: [CalendarDay] = []
    isEmpty = !(statisticsMmonths.count > 0 &&  statisticsMmonths.count >=  self.dateModel.selected.year)
    if !isEmpty {
      let year = statisticsMmonths[self.dateModel.selected.year]
      let monthCount = year.value.count - 1
      let monthIndex = dateModel.selected.month > monthCount ? monthCount : dateModel.selected.month
      let monthKey = dateModel.months[monthIndex].calendarNumber
      days = statisticsMmonths[self.dateModel.selected.year].value[monthKey]?
        .filter { $0.date != nil}
        .map { CalendarDay(day: $0.date!.get(.day), value: $0.activity) } ?? []
      stringDate = "\(statisticsMmonths[dateModel.selected.year].key)-\(monthKey)-03"
    } else {
      let calendar = Calendar.current
      stringDate = "\(calendar.component(.year, from: Date()))-\(calendar.component(.month, from: Date()))-03"
    }

    if let date = Date().fromString(stringDate) {
      return mapData(days: generate(days: days, for: date), mode: mode)
    }
    return []
  }

  private func generate(days: [CalendarDay], for date: Date) -> [CalendarDay] {
    var statisticDays = days
    var statistic: [CalendarDay] = []
    (1...CalendarHelper().daysInMonth(date: date)).forEach {
      if let last = statisticDays.last?.day, last == $0 {
        statistic.append(statisticDays.popLast()!)
      } else {
        statistic.append(CalendarDay(day: $0, value: -1))
      }
    }
    return statistic
  }

  private func mapData(
    days: [CalendarDay],
    mode: ModelEnum? = .calendar(nil)
  ) -> [ModelEnum] {
    let weekdaysFromLastMonth = CalendarHelper().weekdaysFromLast(
      ofMonth: self.dateModel.selected.month - 1,
      year: self.dateModel.selected.year
    )
    var monthDays: [CalendarDay] = []

    if mode == .calendar(nil) {
      (-1*weekdaysFromLastMonth..<0).forEach {
        monthDays.append(CalendarDay(day: $0, value: $0))
      }
    }
    days.forEach {
      monthDays.append($0)
    }
    return monthDays.map(CalendarSectionConfigurator.SectionLayoutEnum.calendar)
  }

  private func tryFetchFromCache(defaults: CopyPsasteUserDefaults) {
    if let cashedStatistic: CashedStatistic = defaults[.statisticCache] {

      statisticsMmonths = Dictionary(grouping: cashedStatistic.statistic, by: { Calendar.current.component(.year, from: $0.date!).description})
        .flatMap {
          [$0.key: Dictionary(grouping: $0.value, by: { Calendar.current.component(.month, from: $0.date!)})]
        }

      let yearsIndex = statisticsMmonths.count - 1
      if yearsIndex < 0 {
        return
      }
      dateModel.selected = (yearsIndex, statisticsMmonths[yearsIndex].value.count - 1)
      dateModel.years = statisticsMmonths.map {$0.key}

      let fmt = DateFormatter()
      fmt.dateFormat = "MMM"
      fmt.locale = .current
      dateModel.months = statisticsMmonths[yearsIndex].value.map {
        return (name: fmt.monthSymbols[$0.key - 1], calendarNumber: $0.key)
      }.reversed()
    }
  }
}
