//
//  Register.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

#if !os(Linux)
import CoreServices
#else
import Glibc
#endif

extension SwordRPC {
  
  func createFile(_ name: String, at path: String, with data: String) {
    let fm = FileManager.default
    
    try? fm.createDirectory(
      atPath: NSHomeDirectory() + path,
      withIntermediateDirectories: true,
      attributes: nil
    )
    
    fm.createFile(
      atPath: path + "/" + name,
      contents: data.data(using: .utf8),
      attributes: nil
    )
  }
  
  func registerUrl() {
    #if !os(Linux)
    guard self.steamId == nil else {
      self.registerSteamGame()
      return
    }
      
    guard let bundleId = Bundle.main.bundleIdentifier else {
      return
    }
    
    let scheme = "discord-\(self.appId)" as CFString
    var response = LSSetDefaultHandlerForURLScheme(scheme, bundleId as CFString)
    
    guard response == 0 else {
      print("[SwordRPC] Error creating URL scheme: \(response)")
      return
    }
    
    let bundleUrl = Bundle.main.bundleURL as CFURL
    response = LSRegisterURL(bundleUrl, true)
      
    if response != 0 {
      print("[SwordRPC] Error registering application: \(response)")
    }
    #else
    var execPath = ""
      
    if let steamId = self.steamId {
      execPath = "xdg-open steam://rungameid/\(steamId)"
    }else {
      let exec = UnsafeMutablePointer<Int8>.allocate(capacity: Int(PATH_MAX) + 1)
      
      defer {
        free(exec)
      }
      
      let n = readLink("/proc/self/exe", exec, Int(PATH_MAX))
      guard n >= 0 else {
        print("[SwordRPC] Error getting game's execution path")
        return
      }
      exec[n] = 0
      
      execPath = String(cString: exec)
    }
      
    self.createFile(
      "discord-\(self.appId).desktop",
      at: "/.local/share/applications",
      with: """
      [Desktop Entry]
      Name=Game \(self.appId)
      Exec=\(execPath) %u
      Type=Application
      NoDisplay=true
      Categories=Discord;Games;
      MimeType=x-scheme-handler/discord-\(self.appId)
      """
    )
    
    let command = "xdg-mime default discord-\(self.appId).desktop x-scheme-handler/discord-\(self.appId)"
      
    if system(command) < 0 {
      print("[SwordRPC] Error registering URL scheme")
    }
    #endif
  }
  
  #if !os(Linux)
  func registerSteamGame() {
    self.createFile(
      "\(self.appId).json",
      at: "/Library/Application Support/discord/games",
      with: """
      {
        "command": "steam://rungameid/\(self.steamId!)"
      }
      """
    )
  }
  #endif
  
}
