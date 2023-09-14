//
//  FaqDataSource.swift
//  MediaMetr
//
//  Created by Maksim Mironov on 03.09.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import UIKit


class FaqDataSource: GroupedTebleviewDatasource<FaqCell, FaqCellHeaderView>, Toggled  {

  var showOptions: ShowOptions! = ShowOptions()
  typealias T = FaqCell

  lazy var imageLoader: ImageLoader = {
    return ImageLoader.shared
  }()

  override init(tableView: UITableView) {
    super.init(tableView: tableView)
    self.tableView.layoutIfNeeded()
    self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    self.headerHeight = 70
    self.useToggle = true
  }

  private func reloadCell(indexPath: IndexPath) {
    DispatchQueue.main.async(execute: { () -> Void in
      self.tableView.beginUpdates()
      self.tableView.reloadRows(at: [indexPath], with: .fade)
      self.tableView.endUpdates()
    })
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sourceData[indexPath.section]
    let model = section.names[indexPath.row]

    switch model {
    case .image(let urlString, let ratio, let options):
    if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier) as? ImageCell {
      cell.image = nil
      cell.clipsToBounds = true
      if let widthRatio = ratio {
        cell.setConstraints(aspect: widthRatio)
        cell.setNeedsLayout()
      }
      cell.imageLoader = imageLoader
      cell.darkImageUrl = options?[FaqItem.OptionKeys.darkValue.rawValue]
      cell.mainImageUrl = urlString
      cell.loadImage(containerWidth: tableView.frame.width, preview: getLocalImage(options: options))
      //                imageLoader.loadImage(from: URL(string: urlString)!) {  [weak self] image in
      //                    guard let self = self else { return }
      //                    DispatchQueue.main.async { [unowned self] in
      //                        guard let img = image ?? self.getLocalImage(options: options) else {
      //                            cell.aspectConstraint = nil
      //                            return
      //                        }
      //                        let widthRatio = tableView.frame.width / img.size.width
      //                        cell.setConstraints(aspect: widthRatio)
      //                        cell.cellImage?.image = img
      //                    }
      //
      //                }
      cell.selectionStyle = .none
      return cell
    }
    default: break
    }
    guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? FaqCell else {
      fatalError("cell with \(String(describing: self.cellIdentifier)) cellIdentifier does not exists")
    }
    cell.configure(model, param: nil)
    cell.selectionStyle = .none
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.layoutIfNeeded()
  }

  func getLocalImage(options: [String: String]?) -> UIImage? {
    guard let localImageUrl = options?["localImage"],
          let localImage = UIImage(named: localImageUrl) else {
      return nil
    }
    return localImage
  }
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerView = super.tableView(tableView, viewForHeaderInSection: section), useToggle {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleToogleSection))
        headerView.addGestureRecognizer(tap)
      return headerView
    }
    return nil
  }
  
  @objc func handleToogleSection(_ sender: UITapGestureRecognizer) {
    guard let section = sender.view?.tag else {return}
      tapToggledSection(section: section)
  }
}
