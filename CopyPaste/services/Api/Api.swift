//
//  Api.swift
//  CompanionApp
//
//  Created by Maksim Mirono on 20.09.2023.
//

import Foundation
import Combine

enum CompanionAppTargetType {
  case auth(AuthType)
}
enum AuthType {
  case code(String)
  case token(String)
  case refresh(String)
  case create
}

extension CompanionAppTargetType: TargetType {

  var baseURL: URL {
    URL(string: "")!
  }

  var path: String {
    var path = ""
    let createAuth: (_ type: AuthType) -> String = { type in
      switch type {
        case .code: return "code"
        case .token: return "token"
        case .refresh: return "refresh"
        case .create: return "code/create"
      }
    }
    switch self {
      case .auth(let authType):
        path = "auth" + "/" + createAuth(authType)
    }
    return path
  }

  var httpMethod: Method? {
    switch self {
    case .auth: return .post
    }
  }
  var headers: [String: String]? {
    switch self {
      case .auth: return ["content-type": "application/json"]
    }
  }

  var task: RequestTask {

//    if case let .auth(code) = self, case let .code(authCode) = code {
//      return .requestJSONEncodable(LoginModel(code: authCode))
//    }
    return .requestData(Data())
  }
}
