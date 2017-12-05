//
//  Delegate.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

public protocol SwordRPCDelegate: class {
  func swordRPCDidConnect(
    _ rpc: SwordRPC
  )

  func swordRPCDidDisconnect(
    _ rpc: SwordRPC,
    code: Int?,
    message msg: String?
  )

  func swordRPCDidReceiveError(
    _ rpc: SwordRPC,
    code: Int,
    message msg: String
  )

  func swordRPCDidJoinGame(
    _ rpc: SwordRPC,
    secret: String
  )

  func swordRPCDidSpectateGame(
    _ rpc: SwordRPC,
    secret: String
  )
  
  func swordRPCDidReceiveJoinRequest(
    _ rpc: SwordRPC,
    request: JoinRequest,
    secret: String
  )
}

extension SwordRPCDelegate {
  public func swordRPCDidConnect(
    _ rpc: SwordRPC
  ) {}

  public func swordRPCDidDisconnect(
    _ rpc: SwordRPC,
    code: Int?,
    message msg: String?
  ) {}

  public func swordRPCDidReceiveError(
    _ rpc: SwordRPC,
    code: Int,
    message msg: String
  ) {}

  public func swordRPCDidJoinGame(
    _ rpc: SwordRPC,
    secret: String
  ) {}

  public func swordRPCDidSpectateGame(
    _ rpc: SwordRPC,
    secret: String
  ) {}

  public func swordRPCDidReceiveJoinRequest(
    _ rpc: SwordRPC,
    request: JoinRequest,
    secret: String
  ) {}
}
