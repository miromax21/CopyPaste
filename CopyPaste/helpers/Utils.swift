//
//  Utils.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 12.10.2022.
//

import Foundation
import os.log
final class Utils {

  static let shared = Utils()
  var debug = false

  init() {
#if DEBUG
  debug = true
#endif
  }
  func getBundleData(fileName: String, type: String? = "plist") -> NSDictionary? {
    guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
      return nil
    }
    return NSDictionary(contentsOfFile: path)
  }

  func dicrionaryToJsonString(dictionaryData: [String: Any]?,
                              removeLiterals: [String]? = ["\n", "\\", "[\\s\n]+"]
  ) -> String {
    guard
      let data = dictionaryData,
      JSONSerialization.isValidJSONObject( dictionaryData ?? [:]),
      let theJSONData = try? JSONSerialization.data(  withJSONObject: data, options: .prettyPrinted),
      let theJSONText = String(data: theJSONData, encoding: .ascii)
    else {
      return dictionaryData != nil ? "\(dictionaryData!)" : ""
    }
    var rval = theJSONText
    removeLiterals?.forEach {
      rval = rval.replacingOccurrences(of: $0, with: " ", options: .regularExpression)
    }
    return rval
  }

  func log(dictionaryData: [String: Any]?, logLevel: Int = 0) {
    guard debug, self.logLevel > 0, logLevel >= self.logLevel else { return }
    os_log("ℹ️ miromaxAlert: %@, level:%@ ",
           log: .default,
           type: .error,
           dicrionaryToJsonString(dictionaryData: dictionaryData), "\(logLevel)")
  }

  func error(dictionaryData: [String: Any]?) {
    guard debug else { return }
    os_log("ℹ️ miromaxAlert: %@, level:%@ ",
           log: .default,
           type: .error,
           dicrionaryToJsonString(dictionaryData: dictionaryData), "\(-1)"
    )
  }

}

extension Utils {
  var logLevel: Int {
    return 1
  }
  var buildType: AppBuildTypeEnum {
    #if DEBUG
      return .dev
    #else
      return .prod
    #endif
  }
}
enum AppBuildTypeEnum {
  case test, dev, prod
  var prefix: String {
    switch self {
    case .test: return "test_"
    case .dev : return "dev_"
    default: return ""
    }
  }
}
