//
//  Events.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

extension SwordRPC {

  public func onConnect(
    handler: @escaping (_ rpc: SwordRPC) -> ()
  ) {
    self.connectHandler = handler
  }

  public func onDisconnect(
    handler: @escaping (_ rpc: SwordRPC, _ code: Int?, _ msg: String?) -> ()
  ) {
    self.disconnectHandler = handler
  }

  public func onError(
    handler: @escaping (_ rpc: SwordRPC, _ code: Int, _ msg: String) -> ()
  ) {
    self.errorHandler = handler
  }

  public func onJoinGame(
    handler: @escaping (_ rpc: SwordRPC, _ secret: String) -> ()
  ) {
    self.joinGameHandler = handler
  }

  public func onSpectateGame(
    handler: @escaping (_ rpc: SwordRPC, _ secret: String) -> ()
  ) {
    self.spectateGameHandler = handler
  }

  public func onJoinRequest(
    handler: @escaping (_ rpc: SwordRPC, _ request: JoinRequest, _ secret: String) -> ()
  ) {
    self.joinRequestHandler = handler
  }

}
