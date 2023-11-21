//
//  roviderFile.swift
//  CompanionApp
//
//  Created by Maksim Mirono on 21.09.2023.
//

import Foundation
import Combine
public protocol ProviderType: AnyObject {
  associatedtype Target: TargetType
}
extension ProviderType {
  var decoder: JSONDecoder {
    JSONDecoder()
  }
  var acceptableStatusCodes: Range<Int> { 200..<300 }

  func validate(response: HTTPURLResponse) throws {
    if acceptableStatusCodes.contains(response.statusCode) {
      return
    }
    throw ProvaiderError.serverError(error(response: response))
  }

  func error(
    response: HTTPURLResponse,
    userInfo: [String: Any]? = nil
  ) -> NSError {
    return NSError(
      domain: response.url?.absoluteString ?? "",
      code: response.statusCode,
      userInfo: userInfo
    )
  }
}

final class Provider<Target: TargetType>: ProviderType {
  func request<T: Decodable>(
    _ target: Target,
    castAs: T.Type,
    session: URLSession! = .shared,
    recive reciveOn: DispatchQueue! = .main
  ) -> AnyPublisher<Request<T>, Error> {
    if let keyDecodingStrategy = target.keyDecodingStrategy {
      decoder.keyDecodingStrategy = keyDecodingStrategy
    }
    return request(target.createRequest(), session: session, recive: reciveOn)
  }

  func request<T: Decodable>(
    _ request: URLRequest,
    session: URLSession! = .shared,
    recive reciveOn: DispatchQueue = .main
  ) -> AnyPublisher<Request<T>, Error> {
    return URLSession.shared
      .dataTaskPublisher(for: request)
      .tryMap { result -> Request<T> in
        guard let response = result.response as? HTTPURLResponse else {
          throw ProvaiderError.unknown
        }
        try self.validate(response: response)
        guard let value = try? self.decoder.decode(T.self, from: result.data) else {
          throw ProvaiderError.decodeError(self.error(response: response, userInfo: ["data": result]))
        }
        return Request(value: value, response: response)
      }
      .receive(on: reciveOn)
      .eraseToAnyPublisher()
  }
}
