//
//  extension.Decodable.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.09.2023.
//

import Foundation

extension Decodable {
  func decode<Container, M>(
    _ container: Container,
    key: Container.Key,
    or defaultValue: M
  ) -> M where M: Decodable, Container: KeyedDecodingContainerProtocol
  {
    return (try? container.decode(M.self, forKey: key)) ?? defaultValue
  }
}
