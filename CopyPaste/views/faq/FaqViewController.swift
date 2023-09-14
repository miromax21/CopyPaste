//
//  FaqViewController.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 06.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//
struct ExpandableNames {
    var isExpanded: Bool
    let sectionName: String
    let names: [String]
}

import UIKit
class FaqViewController: UIViewController, PresentableViewController {

  var presentSize: PresentSize?
  var complete: ((Any?) -> Void)?
  var viewModel: FaqViewModel!

  var dataSource: FaqDataSource!
  let (headerHeight, headerSpace, headerBorderHeight) = (CGFloat(60), CGFloat(5), CGFloat(1))

  lazy var header: UIView = {
    let frameWidth =  self.view.frame.width
    let headerView  = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: self.headerHeight + self.headerSpace))
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: frameWidth, height: self.headerHeight))

    label.text = "FAQ"
    label.textAlignment = .center
    let border = CALayer()
    //  border.backgroundColor = AppColors.control.color.cgColor
    border.frame = CGRect(x: 0, y: (headerHeight - headerBorderHeight), width: frameWidth, height: headerBorderHeight)
    label.layer.addSublayer(border)
    headerView.addSubview(label)

    let button = CustomButton()
    // button.configure(iconparent: headerView)
    button.onClick = { [unowned self] in
        self.dismiss(animated: true)
    }
    headerView.addSubview(button)
    headerView.backgroundColor = AppColors.backgroundMain.color
    return headerView
  }()

  lazy var footer: UIView = {
      let footerView = UIView()
      footerView.backgroundColor = .systemBlue
      footerView.frame.size.height = 100
      return footerView
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: self.view.frame, style: .plain)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(FaqCell.self, forCellReuseIdentifier: FaqCell.identifier)
    tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.identifier)
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.backgroundColor  = AppColors.backgroundMain.color
    return tableView
  }()
  override func viewDidLoad() {
      super.viewDidLoad()
      let nib = UINib(nibName: ImageCell.identifier, bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: ImageCell.identifier)
  }

  func configure() {
      dataSource = FaqDataSource(tableView: tableView)

      viewModel.items.bind { [weak self] items in
          self?.dataSource.initData(items: items)
          UIView.animate(withDuration: 0.3, animations: { [weak self] in
              self?.tableView.alpha = 1
          })
      }
      viewModel.initDatasource()
  }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      view.backgroundColor = AppColors.backgroundMain.color
      let displayFrame = self.view.frame
      tableView.frame =  CGRect(
          x: 0,
          y: (headerHeight + headerSpace),
          width: displayFrame.width,
          height: displayFrame.height - header.frame.height
      )
      self.view.addSubview(header)
      tableView.alpha = 0
      view.addSubview(tableView)
  }

  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      configure()
      tableView.layoutIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let footerView = self.tableView.tableFooterView else {
      return
    }
    let width = self.tableView.bounds.size.width
    let emptyLableForSpace = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 50))
    emptyLableForSpace.backgroundColor = AppColors.backgroundMain.color
    tableView.tableHeaderView = emptyLableForSpace

  let size = footerView.systemLayoutSizeFitting(CGSize(width: width,
                                                       height: UIView.layoutFittingCompressedSize.height)
  )
  if footerView.frame.size.height != size.height {
    footerView.frame.size.height = size.height
    self.tableView.tableFooterView = footerView
  }
  }

  func removeReference() {
      viewModel = nil
  }

  override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      removeReference()
  }
}
