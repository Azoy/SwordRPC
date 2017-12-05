//
//  JoinRequest.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

public struct JoinRequest: Decodable {
  let avatar: String
  let discriminator: String
  let userId: String
  let username: String
  
  enum CodingKeys: String, CodingKey {
    case avatar
    case discriminator
    case userId = "id"
    case username
  }
}
