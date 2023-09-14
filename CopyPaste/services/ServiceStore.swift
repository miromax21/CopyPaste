//
//  ServiceStore.swift
//  CopyPaste
//
//  Created by Maksim Mironov on 14.09.2023.
//

import Foundation
class ServiceStore {
  static var shared = ServiceStore()
  private(set) var location = LocationBecons()
  private(set) var network = NetworkProvider()
  private(set) var defaults = CopyPsasteUserDefaults()
  private(set) var cbObserver: CBUserObserver?
  
  init(){
  //  cbObserver = CBUserObserver(locationService: location)
  }

}
