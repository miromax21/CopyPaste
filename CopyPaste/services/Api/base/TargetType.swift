import Foundation
import Combine

public protocol TargetType {

  /// The target's base `URL`.
  var baseURL: URL { get }

  /// The path to be appended to `baseURL` to form the full `URL`.
  var path: String { get }

  /// The HTTP method used in the request.
  var httpMethod: Method? { get }

  /// The headers to be used in the request.
  var headers: [String: String]? { get }
  var task: RequestTask { get }

  var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? {get}
}
extension TargetType {

  var absoluteURL: URL {
    return baseURL.appendingPathComponent(self.path)
  }

  var headers: [String: String]? {
    return [:]
  }

  var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? {
    return nil
  }

  func createRequest() -> URLRequest {
    var request = URLRequest(url: absoluteURL)
    let task = self.task
    switch task {
    case .requestData(let data):
      request.httpMethod = (httpMethod ?? .post).rawValue
      request.httpBody = data
    case .requestPlain:
      request.httpMethod = (httpMethod ?? .get).rawValue
    case .requestJSONEncodable(let model):
      request.httpMethod = (httpMethod ?? .post).rawValue
      request.httpBody = model.asString?.data(using: .utf8)
    }
    self.headers?.forEach {
      request.setValue($0.value, forHTTPHeaderField: $0.key)
    }
    return request
  }
}
