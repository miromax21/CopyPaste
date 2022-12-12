//
//  GroupedTebleviewDatasource.extentions.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit

protocol Toggled {
  var useToggle: Bool {get set}
  var showOptions: ShowOptions {get set}
  var toogle: ((_ paths: [IndexPath]) -> Void)? {get set}
}

extension GroupedTebleviewDatasource: Toggled {

  func toogleSections(options: ShowOptions, toTop: Bool = true) {

    sourceData[options.section].isExpanded = options.isVisible
    options.isVisible
    ? tableView.insertRows(at: options.indexPaths, with: toTop ? .fade : .automatic)
    : tableView.deleteRows(at: options.indexPaths, with: .automatic)
  }

  func showSection(section sectionIndex: Int) {
    let indexPaths = sourceData[sectionIndex].names.indices.map { IndexPath(row: $0, section: sectionIndex)}
    self.showOptions = ShowOptions(isVisible: true,
                                   section: sectionIndex,
                                   indexPaths: indexPaths
    )
    toogleSections(options: self.showOptions, toTop: sectionIndex < showOptions.section)
    let indexPath = IndexPath(row: 0, section: self.showOptions.section)
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
  }

  func tapToggledSection(section: Int) {
    if !showOptions.isVisible {
      self.showSection(section: section)
      return
    }
    showOptions.isVisible = false
    CATransaction.begin()
    if section != showOptions.section {
      CATransaction.setCompletionBlock({
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) { [unowned self] in
          self.showSection(section: section)
        }
      })
    }
    toogleSections(options: showOptions)
    CATransaction.commit()
  }

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
