//
//  extension.UiImage.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import UIKit
extension UIImage {

  func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
    let format = imageRendererFormat
    format.opaque = isOpaque

    return UIGraphicsImageRenderer(
      size: size,
      format: format
    ).image { _ in
      color.set()
      withRenderingMode(.alwaysTemplate).draw(at: .zero)
    }
  }

  func resizeImage(targetSize: CGSize) -> UIImage {
    let (width, height)    = (self.size.width, self.size.height)
    let widthRatio  = targetSize.width  / width
    let heightRatio = targetSize.height / height
    let newSize     = widthRatio > heightRatio
    ?   CGSize(width: width * heightRatio, height: height * heightRatio)
    :   CGSize(width: width * widthRatio, height: height * widthRatio)

    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}
