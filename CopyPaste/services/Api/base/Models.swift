//
//  Models.swift
//  CompanionApp
//
//  Created by Maksim Mirono on 22.09.2023.
//

import Foundation
public struct Request<T> {
  let value: T
  let response: URLResponse
}
public enum Method: String {
  case get, post, put, deelete, update
  public var value: String {
    return self.rawValue.uppercased()
  }
}
public enum RequestTask {
  case requestPlain
  case requestData(Data)
  case requestJSONEncodable(EncodableJson)
}

enum ProvaiderError: Error {
    case serverError(NSError)
    case decodeError(NSError)
    case unknown
}
