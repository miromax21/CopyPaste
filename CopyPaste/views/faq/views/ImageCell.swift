//
//  ImageCell.swift
//  MediaMetr
//
//  Created by Maksim Mironov on 03.09.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
  var requiredHeight: CGFloat = 0.0
  var image: UIImage?
  var imageLoader: ImageLoader!
  var darkImageUrl: String?
  var mainImageUrl: String?
  var currentUrl: String = ""

  @IBOutlet weak var cellImage: UIImageView!
  @IBOutlet weak var loaderActivity: UIActivityIndicatorView!

  var priority = 1
  override func awakeFromNib() {
    super.awakeFromNib()
    aspectConstraint = nil
    layoutIfNeeded()
  }
  var animate: Bool? {
    willSet {
      guard let newValue = newValue else {return}
      DispatchQueue.main.async { [unowned self] in
        newValue ? loaderActivity.startAnimating() : loaderActivity.stopAnimating()
      }
    }
  }

  internal var aspectConstraint: NSLayoutConstraint? {
    didSet {
      if oldValue != nil {
        animate = false
        cellImage.removeConstraint(oldValue!)
      }
      if aspectConstraint != nil {
        cellImage.addConstraint(aspectConstraint!)
      }
    }
    willSet {
      if newValue == nil {
        animate = true
      }
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    aspectConstraint = nil
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  func setConstraints(aspect: Double) {
    guard let cellImage = cellImage else {return}
    self.backgroundColor = AppColors.backgroundMain.color
    let constraint = NSLayoutConstraint(item: cellImage, attribute: .width, relatedBy: .equal, toItem: cellImage, attribute: .height, multiplier: aspect, constant: 0.0)
    constraint.priority = UILayoutPriority(rawValue: 999)
    aspectConstraint = constraint
  }

  func loadImage(containerWidth: CGFloat, preview: UIImage?, useDark: Bool? = nil) {
    currentUrl = useDark ?? false
    ? darkImageUrl ?? ""
    : mainImageUrl ?? ""
    animate = true
    guard let url = URL(string: currentUrl)  else {return}
    imageLoader.loadImage(from: url) {  [weak self] image, url  in
      guard let self = self else { return }
      self.animate = false
      DispatchQueue.main.async { [weak self] in
        guard let img = image ?? preview, let self = self else {
          self?.aspectConstraint = nil
          return
        }
        let widthRatio = containerWidth / img.size.width
        self.setConstraints(aspect: widthRatio)
        self.cellImage?.image = img
        self.cellImage.alpha = 1
        self.currentUrl = url.absoluteString
      }
    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard #available(iOS 13.0, *) else {return}
    cellImage.alpha = 0
    loadImage(containerWidth: self.frame.width, preview: nil, useDark: false)
  }
}
