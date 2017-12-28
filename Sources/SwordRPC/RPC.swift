//
//  RPC.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Socket

extension SwordRPC {

  func createSocket() {
    do {
      self.socket = try Socket.create(family: .unix, proto: .unix)
      try self.socket?.setBlocking(mode: false)
    }catch {
      guard let error = error as? Socket.Error else {
        print("[SwordRPC] Unable to create rpc socket")
        return
      }

      print("[SwordRPC] Error creating rpc socket: \(error)")
    }
  }

  func send(_ msg: String, _ op: OP) throws {
    let payload = msg.data(using: .utf8)!

    var buffer = UnsafeMutableRawBufferPointer.allocate(count: 8 + payload.count)

    defer { buffer.deallocate() }

    buffer.copyBytes(from: payload)
    buffer[8...] = buffer[..<payload.count]
    buffer.storeBytes(of: op.rawValue, as: UInt32.self)
    buffer.storeBytes(of: UInt32(payload.count), toByteOffset: 4, as: UInt32.self)

    try self.socket?.write(from: buffer.baseAddress!, bufSize: buffer.count)
  }

  func receive() {
    self.worker.asyncAfter(
      deadline: .now() + .milliseconds(self.handlerInterval)
    ) { [unowned self] in
      guard let isConnected = self.socket?.isConnected, isConnected else {
        self.disconnectHandler?(self, nil, nil)
        self.delegate?.swordRPCDidDisconnect(self, code: nil, message: nil)
        return
      }

      self.receive()

      do {
        let headerPtr = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
        let headerRawPtr = UnsafeRawPointer(headerPtr)

        defer {
          free(headerPtr)
        }

        var response = try self.socket?.read(into: headerPtr, bufSize: 8, truncate: true)

        guard response! > 0 else {
          return
        }

        let opValue = headerRawPtr.load(as: UInt32.self)
        let length = headerRawPtr.load(fromByteOffset: 4, as: UInt32.self)

        guard length > 0, let op = OP(rawValue: opValue) else {
          return
        }

        let payloadPtr = UnsafeMutablePointer<Int8>.allocate(capacity: Int(length))

        defer {
          free(payloadPtr)
        }

        response = try self.socket?.read(into: payloadPtr, bufSize: Int(length), truncate: true)

        guard response! > 0 else {
          return
        }

        let data = Data(bytes: UnsafeRawPointer(payloadPtr), count: Int(length))

        self.handlePayload(op, data)

      }catch {
        return
      }
    }
  }

  func handshake() {
    do {
      let json = """
      {
        "v": 1,
        "client_id": "\(self.appId)"
      }
      """

      try self.send(json, .handshake)
    }catch {
      print("[SwordRPC] Unable to handshake with Discord")
      self.socket?.close()
    }
  }

  func subscribe(_ event: String) {
    let json = """
    {
      "cmd": "SUBSCRIBE",
      "evt": "\(event)",
      "nonce": "\(UUID().uuidString)"
    }
    """

    try? self.send(json, .frame)
  }

  func handlePayload(_ op: OP, _ json: Data) {
    switch op {
    case .close:
      let data = self.decode(json)
      let code = data["code"] as! Int
      let message = data["message"] as! String
      self.socket?.close()
      self.disconnectHandler?(self, code, message)
      self.delegate?.swordRPCDidDisconnect(self, code: code, message: message)

    case .ping:
      try? self.send(String(data: json, encoding: .utf8)!, .pong)

    case .frame:
      self.handleEvent(self.decode(json))

    default:
      return
    }
  }

  func handleEvent(_ data: [String: Any]) {
    guard let evt = data["evt"] as? String,
          let event = Event(rawValue: evt) else {
      return
    }

    let data = data["data"] as! [String: Any]

    switch event {
    case.error:
      let code = data["code"] as! Int
      let message = data["message"] as! String
      self.errorHandler?(self, code, message)
      self.delegate?.swordRPCDidReceiveError(self, code: code, message: message)

    case .join:
      let secret = data["secret"] as! String
      self.joinGameHandler?(self, secret)
      self.delegate?.swordRPCDidJoinGame(self, secret: secret)

    case .joinRequest:
      let requestData = data["user"] as! [String: Any]
      let joinRequest = try! self.decoder.decode(
        JoinRequest.self, from: self.encode(requestData)
      )
      let secret = data["secret"] as! String
      self.joinRequestHandler?(self, joinRequest, secret)
      self.delegate?.swordRPCDidReceiveJoinRequest(self, request: joinRequest, secret: secret)

    case .ready:
      self.connectHandler?(self)
      self.delegate?.swordRPCDidConnect(self)
      self.updatePresence()

    case.spectate:
      let secret = data["secret"] as! String
      self.spectateGameHandler?(self, secret)
      self.delegate?.swordRPCDidSpectateGame(self, secret: secret)
    }
  }

  func updatePresence() {
    self.worker.asyncAfter(deadline: .now() + .seconds(15)) { [unowned self] in
      self.updatePresence()

      guard let presence = self.presence else {
        return
      }

      self.presence = nil

      let json = """
          {
            "cmd": "SET_ACTIVITY",
            "args": {
              "pid": \(self.pid),
              "activity": \(String(data: try! self.encoder.encode(presence), encoding: .utf8)!)
            },
            "nonce": "\(UUID().uuidString)"
          }
          """

      try? self.send(json, .frame)
    }
  }

}
