//
//  TableViewDatasource.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import UIKit

protocol ConfigureCellProtocol: UIView {
  associatedtype Model
  var id: String? { get set }
  var showed: Bool? { get set }
  func configure(_:Model, param: [String: Any]?)
}

class DataSource<T: ConfigureCellProtocol>: NSObject, UITableViewDataSource, UITableViewDelegate {

  var count: Int {
    return sourceData.count
  }
  var showPath: ((_ next: IndexPath) -> Void)!
  var animator: Animator?
  weak var targetTableView: UITableView!
  var sourceData: [T.Model] = []
  var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
  var cellIdentifier: String = ""
  var lastShowedCellIndex: Int = 0
  var didSelectIndex: Dynamic<Int?> = Dynamic(nil)

  init(tableView: UITableView, cellIdentifier: String = "cell", cellHeight: CGFloat? = nil) {
    super.init()
    self.targetTableView = tableView
    self.targetTableView.delegate = self
    self.targetTableView.dataSource = self
    self.cellIdentifier = cellIdentifier
    self.targetTableView.rowHeight = UITableView.automaticDimension
    self.targetTableView.estimatedRowHeight = cellHeight ??  UITableView.automaticDimension
  }

  func initData(items: [T.Model], reset: Bool = false) {
    if reset {
      resetList()
    }
    sourceData = items
    insertCells()
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sourceData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = sourceData[indexPath.row]
    let identifier = "\(self.cellIdentifier)"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
      fatalError("cell with \(String(describing: identifier)) cellIdentifier does not exists")
    }
    cell.configure(model, param: nil)
    (cell as? UITableViewCell)?.selectionStyle = .none
    return cell as? UITableViewCell ?? UITableViewCell()
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    lastShowedCellIndex = indexPath.row
    animator?.animate(cell: cell, at: indexPath, in: tableView)
    if showPath != nil {
      showPath(indexPath)
    }

  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    didSelectIndex.value = indexPath.row
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    return footerView
  }

  // MARK: - imsert Cells -
  private func insertCell() {
    currentIndex = IndexPath(row: count - 1, section: 0)
    targetTableView.beginUpdates()
    DispatchQueue.main.async { [unowned self] in
      targetTableView.insertRows(at: [currentIndex], with: .fade)
    }
    targetTableView.endUpdates()
    scrollToCurrentCell()
  }
  private func insertCells() {
    if sourceData.count == 0 {
      return
    }
    targetTableView.reloadData()
  }

  func reloadRow(model: T.Model, indexPath: IndexPath) {
    guard
      self.targetTableView != nil,
      indexPath.row <= sourceData.count
    else { return }
    self.sourceData[indexPath.row] = model
    self.targetTableView.beginUpdates()
    self.targetTableView.reloadRows(at: [indexPath], with: .none)
    self.targetTableView.endUpdates()
  }

  private func resetList() {
    sourceData = []
    targetTableView.reloadData()
  }

  func scrollToCurrentCell(required: Bool = false) {
    DispatchQueue.main.async { [unowned self] in
      if required {
        targetTableView.scrollToRow(at: currentIndex, at: .bottom, animated: true)
        return
      }
      if let visiblePaths = targetTableView.indexPathsForVisibleRows, count - (visiblePaths.last?.row ?? 0) < 4 {
        targetTableView.scrollToRow(at: currentIndex, at: .bottom, animated: true)
      }
    }
  }

  func reloadData() {
    insertCells()
  }

}
