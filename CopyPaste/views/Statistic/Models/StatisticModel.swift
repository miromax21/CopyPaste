//
//  StatisticModel.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 21.04.2023.
//

import Foundation
typealias ModelEnum = CalendarSectionConfigurator.SectionLayoutEnum

class StatisticModel {
  var items: [ModelEnum] = []
  var dateModel: StatisticPickerModel!
  var lastUpdate: String?
  var statisticsMmonths: [(key: String, value: [Int : [Statistic]])] = []
  var statisticSnapshot: [String: CalendarSectionConfigurator.Snapshot] = [:]
  
  func getSnapshot() ->  CalendarSectionConfigurator.Snapshot {
    let items = fetchData(mode: .calendar(nil))
    var snapshot = CalendarSectionConfigurator.Snapshot()
    snapshot.appendSections(["statistic"])
    snapshot.appendItems(items)
    return snapshot
  }
  init() {
    let current = Calendar.current.dateComponents([.month, .year], from: Date())
    let fmt = DateFormatter()
    fmt.dateFormat = "MMM"
    fmt.locale = .current
    dateModel = StatisticPickerModel()
    lastUpdate = ServiceStore.shared.defaults[.lastStatisticUpdate]
    if let cashedStatistic: CashedStatistic = ServiceStore.shared.defaults[.statisticCache] {
      statisticsMmonths = Dictionary(grouping: cashedStatistic.statistic, by: { Calendar.current.component(.year, from: $0.date!).description})
        .flatMap{
          [$0.key: Dictionary(grouping: $0.value, by: { Calendar.current.component(.month, from: $0.date!)})]
        }

      let yearsIndex = statisticsMmonths.count - 1
      if yearsIndex < 0 {
        return
      }
      dateModel.selected = (yearsIndex, statisticsMmonths[yearsIndex].value.count - 1)
      dateModel.years = statisticsMmonths.map{$0.key}
      dateModel.months = statisticsMmonths[yearsIndex].value.map{
        return (name: fmt.monthSymbols[$0.key - 1], calendarNumber: $0.key)
      }.reversed()
    }
  }

  func fetchData( mode: ModelEnum? = .calendar(nil)) -> [ModelEnum] {
    let year = statisticsMmonths[self.dateModel.selected.year]
    let monthCount = year.value.count - 1
    let monthIndex = dateModel.selected.month > monthCount ? monthCount : dateModel.selected.month
    let monthKey = dateModel.months[monthIndex].calendarNumber
    let mock = statisticsMmonths[self.dateModel.selected.year].value[monthKey]?
      .filter { $0.date != nil}
      .map { CalendarDay(day: $0.date!.get(.day), value: $0.activity) } ?? []
    let stringDate = "\(statisticsMmonths[dateModel.selected.year].key)-\(monthKey)-03"
    if let date = Date().fromString(stringDate) {
     return mapData(days: generate(days: mock, for: date), mode: mode)
    }
    return []
  }

  func generate(days: [CalendarDay], for date: Date) -> [CalendarDay] {
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

  func mapData(
    days: [CalendarDay],
    mode: ModelEnum? = .calendar(nil)
  ) ->  [ModelEnum] {
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

}
