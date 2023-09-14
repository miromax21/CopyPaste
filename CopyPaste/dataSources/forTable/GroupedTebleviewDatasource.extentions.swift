//
//  GroupedTebleviewDatasource.extentions.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 13.10.2022.
//

import Foundation
import UIKit

protocol Toggled: NSObject, UITableViewDataSource  {
  associatedtype T:ConfigureTableCell
  var useToggle: Bool {get set}
  var showOptions: ShowOptions! {get set}
  var toogle: ((_ paths: [IndexPath]) -> Void)? {get set}
  var sourceData: [ExpandableCels<T.M>] { get set }
  var tableView: UITableView!{ get set }
}
extension Toggled {
      func toogleSections(options: ShowOptions, toTop: Bool = true) {
        if options.section > sourceData.count {
          return
        }
        sourceData[options.section].isExpanded = options.isVisible
        options.isVisible
          ? tableView.insertRows(at: options.indexPaths, with: toTop ? .fade : .automatic)
          : tableView.deleteRows(at: options.indexPaths, with: .automatic)
      }
      
      func showSection(section sectionIndex: Int) {
        self.showOptions = ShowOptions(
          isVisible: true,
          section: sectionIndex,
          indexPaths: sourceData[sectionIndex].names.indices.map { IndexPath(row: $0, section: sectionIndex)}
        )
      
          toogleSections(options: self.showOptions, toTop: sectionIndex < showOptions.section)
          let indexPath = IndexPath(row: 0, section: self.showOptions.section)
          self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
      }
      
      func tapToggledSection(section: Int){
          if !showOptions.isVisible{
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
}
