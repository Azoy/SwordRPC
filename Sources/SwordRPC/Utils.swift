//
//  Utils.swift
//  SwordRPC
//
//
//  Utils.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

extension SwordRPC {

  func getTmpPath() -> String {
    let currentProcess = ProcessInfo.processInfo

    if let path = currentProcess.environment["XDG_RUNTIME_DIR"] {
      return path
    }

    if let path = currentProcess.environment["TMPDIR"] {
      return path
    }

    if let path = currentProcess.environment["TMP"] {
      return path
    }

    if let path = currentProcess.environment["TEMP"] {
      return path
    }

    return "/tmp"
  }
  
  func encode(_ value: Any) -> Data {
    do {
      return try JSONSerialization.data(withJSONObject: value, options: [])
    }catch {
      return Data()
    }
  }
  
  func decode(_ json: Data) -> [String: Any] {
    do {
      return try JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
    }catch {
      return [:]
    }
  }
  
}
