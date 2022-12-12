//
//  DataCache.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import Foundation
import UIKit.UIImage
// import Combine

// Declares in-memory image cache
public protocol DataCacheType: AnyObject {
  func data(for url: URL) -> Data?
  func insertData(_ data: Data?, for url: URL)
  func removeData(for url: URL)
  func removeAllData()
  subscript(_ url: URL) -> Data? { get set }
}

public final class DataCache: DataCacheType {

  // 1st level cache, that contains encoded images
  private lazy var dataCache: NSCache<AnyObject, AnyObject> = {
    let cache = NSCache<AnyObject, AnyObject>()
    cache.countLimit = config.countLimit
    return cache
  }()
  //    // 2nd level cache, that contains decoded images
  //    private lazy var decodedDataCache: NSCache<AnyObject, AnyObject> = {
  //        let cache = NSCache<AnyObject, AnyObject>()
  //        cache.totalCostLimit = config.memoryLimit
  //        return cache
  //    }()
  private let lock = NSLock()
  private let config: Config

  public struct Config {
    public let countLimit: Int
    public let memoryLimit: Int
    public static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
  }

  public init(config: Config = Config.defaultConfig) {
    self.config = config
  }

  public func data(for url: URL) -> Data? {
    lock.lock(); defer { lock.unlock() }
    //        if let decodedData = decodedDataCache.object(forKey: url as AnyObject) as? Data {
    //            return decodedData
    //        }
    if let data = dataCache.object(forKey: url as AnyObject) as? Data {
      return data
    }
    return nil
  }

  public func insertData(_ data: Data?, for url: URL) {
    guard let data = data else { return removeData(for: url) }
    //  let decompressedImage = image.decodedImage()

    lock.lock(); defer { lock.unlock() }
    dataCache.setObject(data as AnyObject, forKey: url as AnyObject, cost: 1)
    //   decodedDataCache.setObject(data as AnyObject, forKey: url as AnyObject, cost: Int(data.getSizeInMB()))
  }

  public func removeData(for url: URL) {
    lock.lock(); defer { lock.unlock() }
    dataCache.removeObject(forKey: url as AnyObject)
    //  decodedDataCache.removeObject(forKey: url as AnyObject)
  }

  public func removeAllData() {
    lock.lock(); defer { lock.unlock() }
    dataCache.removeAllObjects()
    //  decodedDataCache.removeAllObjects()
  }

  public subscript(_ key: URL) -> Data? {
    get {
      return data(for: key)
    }
    set {
      return insertData(newValue, for: key)
    }
  }
}
