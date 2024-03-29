//
//  GroupedTebleviewDatasource.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 02.12.2022.
//

import Foundation
import UIKit
struct ExpandableCels<T> {
  var isExpanded: Bool
  let sectionName: String
  var names: [T]
  var floatSection = false
}
protocol ConfigureHeaderViewProtocol: UIView {
  associatedtype M
  func configure(_:M, param: [String: Any]?)
}
struct ShowOptions {
  var isVisible: Bool = false
  var section: Int = 0
  var indexPaths: [IndexPath] = []
}

class GroupedTebleviewDatasource<T: ConfigureTableCell, H: ConfigureHeaderViewProtocol>: NSObject, UITableViewDataSource, UITableViewDelegate {

  var count: Int {
    return sourceData.count
  }
  var showPath: ((_ next: T) -> Void)!
 // var showOptions = (isVisible: false, section: 0, indexPaths: [IndexPath]())
  var useToggle: Bool = false

  var toogle: ((_ paths: [IndexPath]) -> Void)?

  var tableView: UITableView!
  var sourceData: [ExpandableCels<T.M>] = []
  var currentInsertIndex: IndexPath = IndexPath(row: 0, section: 0)
  var cellIdentifier: String = ""
  var headerHeight: CGFloat = UITableView.automaticDimension


  var saveShowCellId: Bool = false
  var readedIds: [String] = []
  var headerColor: UIColor = AppColors.backgroundMain.color

  init(tableView: UITableView) {
    self.tableView = tableView
    self.cellIdentifier = T.identifier
    super.init()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.sectionHeaderHeight = UITableView.automaticDimension
    self.tableView.estimatedSectionHeaderHeight = 25
    self.tableView.register(T.self, forCellReuseIdentifier: T.identifier)
  }

  func initData(items: [Substring: [T.M]]) {
    sourceData = items.map {
      return ExpandableCels<T.M>(
        isExpanded: true,
        sectionName: String($0.key),
        names: $0.value
      )
    }.sorted(by: {
      Date().fromString($0.sectionName)?.compare(Date().fromString($1.sectionName) ?? Date()) == .orderedDescending
    })
    insertCells()
  }

  func initData(items: [ExpandableCels<T.M>]) {
    sourceData = items
    insertCells()
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return sourceData.count
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.headerHeight
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let faqheaderView = H(frame: CGRect(x: 10, y: 10, width: tableView.frame.width - 20, height: 50))
    if let sectionName = sourceData[section].sectionName as? H.M {
      faqheaderView.configure(
        sectionName,
        param: ["section": section, "isfloatCell": sourceData[section].floatSection]
      )
    }
    let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: faqheaderView.frame.width, height: faqheaderView.frame.height + 20))
    headerView.addSubview(faqheaderView)
    headerView.backgroundColor = self.headerColor
    headerView.tag = section
    return headerView
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !sourceData[section].isExpanded {
      return 0
    }
    return sourceData[section].names.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let section = sourceData[indexPath.section]
    let model = section.names[indexPath.row]
    let identifier = "\(self.cellIdentifier)"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? T else {
      fatalError("cell with \(String(describing: identifier)) cellIdentifier does not exists")
    }
    cell.configure(model, param: nil)
    if let idModel = model as? (any Identifiable), cell.id == nil {
      cell.id = "\(idModel.id)"
    }
    if saveShowCellId, let id = cell.id, !readedIds.contains(id) {
      cell.showed = true
      readedIds.append(id)
    }

    return cell
  }

  func insertCell(at indexPath: IndexPath, model: [T.M]) {
    sourceData[indexPath.section].names.insert(contentsOf: model, at: indexPath.row)

    DispatchQueue.main.async { [unowned self] in
      tableView.beginUpdates()
      tableView.insertRows(at: [indexPath], with: .fade)
      tableView.endUpdates()
      scrollToCurrentCell()
    }
  }

  private func insertCells() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
      self?.scrollToCurrentCell(required: true)
    }
  }
}
extension GroupedTebleviewDatasource {
  func scrollToCurrentCell(required: Bool = false) {

    if currentInsertIndex.row == 0 {
      return
    }
    if required {
      tableView.scrollToRow(at: currentInsertIndex, at: .bottom, animated: true)
      return
    }
    if let visiblePaths = tableView.indexPathsForVisibleRows, count - (visiblePaths.last?.row ?? 0) < 4 {
      tableView.scrollToRow(at: currentInsertIndex, at: .bottom, animated: true)
    }
  }
}
