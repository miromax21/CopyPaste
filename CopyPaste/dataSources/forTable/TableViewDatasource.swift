//
//  DataSource.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 25.11.2022.
//

import Foundation
import Foundation
import UIKit

protocol ConfigureTableCell: UITableViewCell {
  associatedtype M
  var id: String? { get set }
  var showed: Bool? { get set }
  func configure(_:M, param: [String: Any]?)
}
protocol RenderedView {
  func render(params: [String:Any]?)
}

final class DataSource<T: ConfigureTableCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
  private var sourceData: [T.M] = []
  var count: Int {
    return sourceData.count
  }
  var showPath: ((_ next: IndexPath) -> Void)!
  var animator: Animator?
  weak var targetTableView: UITableView!

  var currentIndex: IndexPath = IndexPath(row: 0, section: 0)
  var cellIdentifier: String = ""
  var lastShowedCellIndex: Int = 0
  @Published var didSelectIndex: IndexPath? = nil

  init(tableView: UITableView, cellHeight: CGFloat? = nil) {
    super.init()
    self.targetTableView = tableView
    self.targetTableView.delegate = self
    self.targetTableView.dataSource = self
    self.cellIdentifier = T.identifier
    self.targetTableView.rowHeight = UITableView.automaticDimension
    self.targetTableView.estimatedRowHeight = cellHeight ??  UITableView.automaticDimension
    self.targetTableView.register(T.self, forCellReuseIdentifier: T.identifier)
//    let animation = Animator.makeFadeAnimation(duration: 0.9, delayFactor: 0.05)
//    animator = Animator(animation: animation)
  }
  
  func getModel(for index: IndexPath) -> T.M? {
    return sourceData[index.row]
  }

  func initData(items: [T.M], reset: Bool = false) {
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
    let identifier = T.identifier
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
      fatalError("cell with \(String(describing: identifier)) cellIdentifier does not exists")
    }
    if let model = getModel(for: indexPath) {
      cell.configure(model, param: nil)
    }
    cell.selectionStyle = .none
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    lastShowedCellIndex = indexPath.row
    animator?.animate(cell: cell, at: indexPath, in: tableView)
    if showPath != nil {
      showPath(indexPath)
    }
    
    if let cell = cell as? RenderedView {
      cell.render(params: ["last": indexPath.row == sourceData.count - 1])
//      cell.render(position: indexPath.row, total: sourceData.count)
//      cell.animate(position: indexPath.row)
    }

  }
  
//  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//      if shouldAnimateCells, let placeCell = cell as? PlaceCell {
//          placeCell.render(position: indexPath.row, total: places.count)
//          placeCell.animate(position: indexPath.row)
//      }
//  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    didSelectIndex = indexPath
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

  func reloadRow(model: T.M, indexPath: IndexPath) {
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
