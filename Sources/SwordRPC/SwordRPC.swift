//
//  SwordRPC.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Socket

public class SwordRPC {

  // MARK: App Info
  public let appId: String
  public var handlerInterval: Int
  public let autoRegister: Bool
  public let steamId: String?

  // MARK: Technical stuff
  let pid: Int32
  var socket: Socket? = nil
  let worker: DispatchQueue
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  var presence: RichPresence? = nil

  // MARK: Event Handlers
  var connectHandler:      (_ rpc: SwordRPC) -> () = {_ in}
  var disconnectHandler:   (_ rpc: SwordRPC, _ code: Int?, _ msg: String?) -> () = {_, _, _ in}
  var errorHandler:        (_ rpc: SwordRPC, _ code: Int, _ msg: String) -> () = {_, _, _ in}
  var joinGameHandler:     ((_ rpc: SwordRPC, _ secret: String) -> ())? = nil
  var spectateGameHandler: ((_ rpc: SwordRPC, _ secret: String) -> ())? = nil
  var joinRequestHandler:  ((_ rpc: SwordRPC, _ secret: String, _ request: JoinRequest) -> ())? = nil

  public init(
    appId: String,
    handlerInterval: Int = 1000,
    autoRegister: Bool = true,
    steamId: String? = nil
  ) {
    self.appId = appId
    self.handlerInterval = handlerInterval
    self.autoRegister = autoRegister
    self.steamId = steamId

    self.pid = ProcessInfo.processInfo.processIdentifier
    self.worker = DispatchQueue(label: "me.azoy.swordrpc.\(pid)", qos: .userInitiated)
    self.encoder.dateEncodingStrategy = .secondsSince1970

    self.createSocket()

    self.registerUrl()
  }

  public func connect() {
    let tmp = self.getTmpPath()

    guard let socket = self.socket else {
      print("[SwordRPC] Unable to connect")
      return
    }

    for i in 0 ..< 10 {
      try? socket.connect(to: "\(tmp)/discord-ipc-\(i)")

      guard !socket.isConnected else {
        self.handshake()
        self.receive()

        if self.joinGameHandler != nil {
          self.subscribe("ACTIVITY_JOIN")
        }

        if self.spectateGameHandler != nil {
          self.subscribe("ACTIVITY_SPECTATE")
        }

        if self.joinRequestHandler != nil {
          self.subscribe("ACTIVITY_JOIN_REQUEST")
        }

        return
      }
    }

    print("[SwordRPC] Discord not detected")
  }

  public func setPresence(_ presence: RichPresence) {
    self.presence = presence
  }

  public func reply(to request: JoinRequest, with reply: JoinReply) {
    let json = """
    {
      "cmd": "\(reply == .yes ? "SEND_ACTIVITY_JOIN_INVITE" : "CLOSE_ACTIVITY_JOIN_REQUEST")",
      "args": {
        "user_id": "\(request.userId)"
      }
    }
    """

    try? self.send(json, .frame)
  }

}
