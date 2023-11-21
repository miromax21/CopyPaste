//
//  RemotePopUpservice.swift
//  CompanionApp
//
//  Created by Maksim Mironov on 28.08.2023.
//

import UIKit

final class RemotePopUpservice {
// MARK: - StatisticConfiguration -
  let statisticConfigurator = CalendarSectionConfigurator([0: .calendar(nil)])
  var statisticModel: StatisticModel!
  init(statisticModel: StatisticModel!) {
    self.statisticModel = statisticModel
  }
  func getStatisticConfiguration() -> SelectViewModeConfiguration {
    let statisticConfiguration = SelectViewModeConfiguration(
      horizontallMetrics: [.topView: "H:|-15-[v0]-15-|", .bottomView: "H:|-15-[v0]-15-|", .listView: "H:|-15-[v0]-15-|"],
      vertivalMetrics: [.topView: 80, .bottomView: 60, .listView: 400]
    ) { [weak self, statisticConfigurator] listView in
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
    lastDateLabel.text = "Loc(Loc.Global.date_lastSynchronise)"
    let dateLabel = UILabel()
    dateLabel.text = lastUpdate ?? "__.__.____"
    dateLabel.textAlignment = .right
    [dateLabel, lastDateLabel].forEach {
      lsastUpdateView.addSubview($0)
      lsastUpdateView.addConstraintsWithFormat("V:|[v0]|", views: $0)
    }
    lsastUpdateView.addConstraintsWithFormat("H:|[v0]-[v1]|", views: lastDateLabel, dateLabel)
    statisticConfiguration.bottomView = .someView(lsastUpdateView)
    return statisticConfiguration
  }

  internal var configurator: SectionConfigurator! = SectionConfigurator(["": .tvSet])

// MARK: - GuestsConfiguration -
//  var guestsDatasource: GuestsSource?
//  var guests: [Int: [Guest]] = [:]

//  func getGuestsConfiguration(gender: Int?, update: Bool = false) -> SelectViewModeConfiguration? {
//    guard
//      case let .success(data) = ServiceStore.shared.network.state,
//      let deviceState = data[0]
//    else { return nil}
//    let sections: [SectionModel<Guest?>] = deviceState.guests.map {
//      SectionModel(items: $0.value, at: $0.key)
//    }
//
//    let selectedGender = gender ?? guestsDatasource?.currentSection
//    let selectedIndex = sections.firstIndex{$0.layoutIndex == selectedGender} ?? 0
//    if guestsDatasource == nil {
//      let config = createGuestConfig(sections: sections)
//      return config
//    }
//    if update {
//      sections.forEach{
//        guestsDatasource?.setSection($0)
//      }
//    }
//    if gender != nil {
//      guestsDatasource?.currentSection = selectedIndex
//    }
////    guestsDatasource?.currentSection = selectedIndex
//    guestsDatasource?.updateCollection?()
//    return nil
//  }
//
//  private func createGuestConfig(sections: [SectionModel<Guest?>]) -> SelectViewModeConfiguration {
//    guestsDatasource =
//    GuestsSource(sections: sections, config: configurator) { [weak self] collectionView, indexPath, model in
//      guard
//        let model = model.items?[indexPath.row] as? GuestCell.CellModel,
//        let cell = self?.configurator.buildItem(model: model, collectionView, IndexPath(row: indexPath.row, section: self?.guestsDatasource?.currentSection ?? 0)) as GuestCell?
//      else { fatalError("\(GuestCell.identifier) not registered") }
//      cell.emit = { [weak self] updateModel in
//        self?.guestsDatasource?.update(for: indexPath, with: updateModel)
//      }
//      self?.guestsDatasource?.updateCollection = {
//        collectionView.reloadData()
//      }
//      return cell
//    }
//    let configuration = SelectViewModeConfiguration(
//      horizontallMetrics: [.topView: "H:[v0(>=100,<=360)]"],
//      vertivalMetrics: [.topView: 34, .bottomView: 60, .listMin: 400]
//    ) { [weak self] listView in
//
//      if let listView = listView as? ListView {
//        listView.registertSubViews(cells: GuestCell.self)
//        listView.update(source: self?.guestsDatasource)
//      }
//    }
//    configuration.setCollection(
//      layout: UICollectionViewCompositionalLayout { (_, envir) -> NSCollectionLayoutSection? in
//        let config: SectionConfigurator.SectionLayoutEnum = .guests
//        return config.layoutSection(envir)
//      }
//    )
//    let topViewSegmentedControl = CustomSegmentedControl(
//      items: [Loc(Loc.Global.gender_female), Loc(Loc.Global.gender_male)]
//    )
//    configuration.topView = .someView(topViewSegmentedControl)
//    configuration.bottomView = .defaultForPlacement(Loc(Loc.Global.btn_apply))
//    return configuration
//  }

}
