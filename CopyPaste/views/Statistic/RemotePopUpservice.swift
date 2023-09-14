//
//  RemotePopUpservice.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.09.2023.
//

import UIKit

class RemotePopUpservice{
  let statisticConfigurator = CalendarSectionConfigurator([0: .calendar(nil)])
  lazy var statisticModel: StatisticModel = {
    StatisticModel()
  }()
  func getStatisticConfiguration() -> SelectViewModeConfiguration {
    let statisticConfiguration = SelectViewModeConfiguration(
      horizontallMetrics: [.topView: "H:|-15-[v0]-15-|", .bottomView: "H:|-15-[v0]-15-|", .listMin: "H:|-15-[v0]-15-|"],
      vertivalMetrics: [.topView: 80, .bottomView: 60, .listMin: 400]
    ){ [weak self, statisticConfigurator] listView in
      if let listView = listView as? ListView {
        listView.isScrollEnabled = false
        listView.registertSubViews(cells: CalendarCell.self, MonthCell.self)
        if let statisticModel = self?.statisticModel {
          DispatchQueue.main.async {
            statisticConfigurator.configureDatasource(collectionView: listView)
            self?.statisticConfigurator.apply(snapshot: statisticModel.getSnapshot())
          }
        }
        listView.update(
          source: statisticConfigurator.dataSource,
          layout: statisticConfigurator.layout
        )
      }
    }
    let topView = StatisticTopView()
    topView.model = statisticModel
    topView.emit = { [weak self] model in
      if let statisticModel = self?.statisticModel {
        statisticModel.dateModel = model
        DispatchQueue.main.async {
          self?.statisticConfigurator.apply(snapshot: statisticModel.getSnapshot())
        }
      }
    }
    statisticConfiguration.topView = .someView(topView)
    statisticConfiguration.setCollection(layout: statisticConfigurator.layout)
    let lastUpdate = statisticModel.lastUpdate
    let lsastUpdateView = UIView()
    let lastDateLabel = UILabel()
    lastDateLabel.text = "статистика"
    let dateLabel = UILabel()
    dateLabel.text = lastUpdate ?? "__.__.____"
    dateLabel.textAlignment = .right
    [dateLabel, lastDateLabel].forEach{
      lsastUpdateView.addSubview($0)
      lsastUpdateView.addConstraintsWithFormat("V:|[v0]|", views: $0)
    }
    lsastUpdateView.addConstraintsWithFormat("H:|[v0]-[v1]|", views: lastDateLabel, dateLabel)
    statisticConfiguration.bottomView = .someView(lsastUpdateView)
    return statisticConfiguration
  }

}
