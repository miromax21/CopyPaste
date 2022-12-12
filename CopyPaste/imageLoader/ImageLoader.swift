//
//  ImageLoader.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

/*
 @author: Max  sgl0v
 @link: https://github.com/sgl0v/OnSwiftWings/blob/master/ImageCache.playground/Sources/ImageLoader.swift
 */
import Foundation
import UIKit.UIImage
import Combine

public final class ImageLoader {
  public static let shared = ImageLoader()
  private let cache: ImageCacheType
  private lazy var backgroundQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    return queue
  }()

  var session: URLSession!

  public init(cache: ImageCacheType = ImageCache()) {
    self.cache = cache
    session = URLSession.shared
  }

  func loadImage(from url: URL, completionHandler: @escaping  ((UIImage?, URL) -> Void)) -> Cancelable? {
    if let image = cache.image(for: url) {
      completionHandler(image, url)
      return nil
    }
    let queue = DispatchQueue.global(qos: .userInteractive)
    let workItem = DispatchWorkItem(qos: .background) {
      if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
        self.cache.insertImage(img, for: url)
        completionHandler(img, url)
      }
    }
    queue.async(execute: workItem)
    return workItem as? Cancelable
  }
}

protocol Cancelable {
  func cancel()
}
