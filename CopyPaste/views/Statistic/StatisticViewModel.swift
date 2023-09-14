////
////  StatisticViewModel.swift
////  CopyPaste
////
////  Created by Maksim Mironov on 11.10.2022.
////
//
//import Foundation
//final class StatisticViewModel: BaseViewModel {
//  var items = Dynamic([CalendarDay]())
//  var selecrDate: Date = Date()
//  override init(coordinator: BaseCoordinator) {
//    super.init(coordinator: coordinator)
//  }
//
//  func fetchUsers(selectedDate: Date = Date()) {
//    self.selecrDate = selectedDate
//    var items: [CalendarDay] = []
//    (1...31).forEach {
//      items.append(CalendarDay(day: $0, value: Int.random(in: 10..<101)))
//    }
//    let nextItems = mapMonth(items: items, selectedDate: selecrDate)
//    self.items.value = nextItems
//  }
//
//  private func mapMonth(items: [CalendarDay], selectedDate: Date = Date()) -> [CalendarDay]{
//    var items = items
//    var lastItem = items.popLast()
//    var totalSquares =  [CalendarDay]()
//    let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
//    let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
//    let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
//    var count: Int = 1
//    while(count <= 42) {
//      if(count <= startingSpaces || count - startingSpaces > daysInMonth) {
//        totalSquares.append(CalendarDay(day: -1 * count, value: nil))
//      } else {
//        let dayNumber = count - startingSpaces
//        if let lastItem = items.first(where: { $0.day == dayNumber}) {
//          totalSquares.append(lastItem)
//        } else {
//          totalSquares.append(CalendarDay(day: dayNumber, value: nil))
//        }
////        items[count - 1]
//      }
//      count += 1
//    }
//    return totalSquares
//  }
//}
//
//struct CalendarDay: Hashable {
//  let day: Int
//  let value: Int?
//  var indication: ValueIndication {
//    return ValueIndication(value: value)
//  }
//
//  enum ValueIndication {
//    case none, bad, good, nice, greate
//    init(value: Int?) {
//      guard let value = value else {
//        self = .none
//        return
//      }
//      switch value {
//      case _ where value < 25:  self = .bad; break
//      case _ where value < 49:  self = .good; break
//      case _ where value < 74:  self = .nice; break
//      case 75...100:  self = .greate
//      default: self = .none
//      }
//    }
//    var color: AppColors {
//      var color: AppColors
//      switch self{
//        case .none: color = .none
//        case .bad: color = .alertError
//        case .good: color = .none
//        case .nice: color = .alertWarning
//        case .greate: color = .alertInfo
//      }
//      return color
//    }
//  }
//}
