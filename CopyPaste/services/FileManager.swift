//
//  FileManager.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 17.09.2021.
//  Copyright © 2021 Anitaa. All rights reserved.
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
protocol ReadWriteManager {
  mutating func loadJSON(fileUrl: URL?) throws -> String?
  mutating func loadData(fileUrl: URL?) throws -> (data: Data, mimeType: String)?
  mutating func save(jsonObject: [String: Any]?, fileName: String, useEncrypr: Bool) throws -> Bool
  mutating func save(jsonObject: Data?, fileName: String, useEncrypr: Bool) throws -> Bool
  func removeFile(targetFile path: URL?)
  func removeFile(targetFile name: String)
  func listFilesFromDocumentsFolder(completion: @escaping ([URL]) -> Void)
  var path: String {get}
  var fullPath: URL? {get}
}

struct DataFileManager: ReadWriteManager {
  var path = "temp"
  var manager = FileManager.default
  var fullPath: URL? {
    let rootFolderURL = try? manager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    return rootFolderURL?.appendingPathComponent(self.path)
  }

  lazy var crypto: Crypto? = {
    let pkey = "publicKey".replacingOccurrences(of: "\\n", with: "\n", options: .literal)
    return Crypto(pkey, "deviceid")
  }()

  mutating func loadJSON(fileUrl: URL? = nil) throws -> String? {
    guard
      let fileURL = fileUrl ?? (try? getFile()),
      let savedText = try? String(contentsOf: fileURL)
    else {
      return nil
    }
    return savedText
  }

  mutating func loadData(fileUrl: URL? = nil) throws -> (data: Data, mimeType: String)? {
    guard
      let fileURL = fileUrl ?? (try? getFile()),
      manager.fileExists(atPath: fileURL.relativePath),
      let savedData = try? Data(contentsOf: fileURL)
    else {
      return nil
    }
    return (savedData, mimeTypeForPath(path: fileURL))
  }

  mutating func save(jsonObject: Data?, fileName: String = "", useEncrypr: Bool = true) -> Bool {
    guard
      let jsonObject = jsonObject,
      let fileURL = try? getFile(forSaving: true, fileName: fileName),
      let jsonData = useEncrypr ? crypto?.my_encryptData(jsonObject) : jsonObject
    else {
      return false
    }
    do {
      try jsonData.write(to: fileURL)
      return true
    } catch {
      Utils.shared.error(dictionaryData: ["save error": error])
      return false
    }
  }

  mutating func save(jsonObject: [String: Any]?, fileName: String, useEncrypr: Bool = true) throws -> Bool {
    guard
      let theJSONData = try? JSONSerialization.data( withJSONObject: jsonObject as Any, options: .prettyPrinted )
    else {
      return false
    }
    return save(jsonObject: theJSONData, fileName: fileName, useEncrypr: useEncrypr)
  }

  func removeFile(targetFile url: URL?) {
    guard
      let path = url?.relativePath,
      manager.fileExists(atPath: path)
    else { return }

    do {
      try FileManager.default.removeItem(atPath: path)
    } catch let error {
      Utils.shared.log(dictionaryData: ["removeFile error": error])
    }
  }

  func removeFile(targetFile name: String) {
    var path = fullPath
    path?.appendPathComponent(name)
    removeFile(targetFile: path)
  }

  func getFile(forSaving: Bool = false, fileName: String = "") throws -> URL {
    let rootFolderURL = try manager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )

    let nestedFolderURL = rootFolderURL.appendingPathComponent(self.path)
    if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
      if !forSaving {
        fatalError("path doesn't exist")
      }
      try manager.createDirectory(
        at: nestedFolderURL,
        withIntermediateDirectories: false,
        attributes: nil
      )
    }
    return nestedFolderURL.appendingPathComponent("\(fileName)")
  }

  func listFilesFromDocumentsFolder(completion: @escaping ([URL]) -> Void) {
    guard
      let rootFolderURL = try?
        manager.url(
          for: .documentDirectory,
          in: .userDomainMask,
          appropriateFor: nil,
          create: false
        ),
      let directoryContents = try?
        FileManager.default.contentsOfDirectory(
          at: rootFolderURL.appendingPathComponent(self.path),
          includingPropertiesForKeys: nil
        )
    else {
      return
    }
    completion(directoryContents)
  }

  func mimeTypeForPath(path: URL) -> String {
    let pathExtension = path.pathExtension
    if #available(iOS 14.0, *), let type = UTType(filenameExtension: pathExtension) {
      if let mimetype = type.preferredMIMEType {
        return mimetype as String
      }
    }
    return "application/octet-stream"
  }
}
