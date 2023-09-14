//
//  FaqCell.swift
//  OnboardingExample
//
//  Created by Maksim Mironov on 06.08.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import UIKit
enum FaqCellTypeEnum {
  case text(text: String), title(text: String), image(url: String, ratio: Double?, options: [String: String]?)
}
class FaqCell: UITableViewCell, ConfigureTableCell {
  var showed: Bool?
  var id: String?
  typealias M = FaqCellTypeEnum

  var image: UIImage?
  var cellImage: UIImage? {
    willSet {
      guard let next = newValue else {
        imageView?.image = nil
        setNeedsLayout()
        return
      }

      imageView?.image = next
      imageView?.contentMode = .scaleAspectFill
      imageView?.center = contentView.center
      setNeedsLayout()
    }
  }
  func configure(_ model: M, param: [String: Any]? = nil) {
    image = nil
    switch model {
    case .image(let url, _, _):
      cellImage = UIImage(named: url) ?? nil
    case .text(let text):
      textLabel?.text = text
      textLabel?.font = FontsEnum.base.getFont(size: 15)
    case .title(let text):
      textLabel?.text = text
      textLabel?.font = FontsEnum.base.getFont(size: 20)
    }
    textLabel?.numberOfLines = 0
    self.backgroundColor = AppColors.backgroundMain.color
    textLabel?.sizeToFit()
  }
  override func prepareForReuse() {
    imageView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    super.prepareForReuse()
    cellImage = nil
    textLabel?.text = ""
  }

  func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
    UIGraphicsBeginImageContext( newSize )
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!.withRenderingMode(.alwaysTemplate)
  }
}
