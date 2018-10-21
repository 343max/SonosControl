// Copyright Max von Webel. All Rights Reserved.

import Foundation

/*
 
 {
 "access_token":"a5771c41-f3e3-45de-a0dc-311ff03816dc",
 "token_type":"Bearer",
 "expires_in":86400,
 "refresh_token":"5f6e38ed-144e-43a1-abd8-98449cd0a3a3",
 "resource_owner":"997007071",
 "scope":"scope_test"
 }
 
*/

struct CreateTokenResponse: Decodable {
  let accessToken: String
  let tokenType: String
  let expires: Date
  let refreshToken: String
  let resourceOwner: String
  let scope: String
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case resourceOwner = "resource_owner"
    case scope = "scope"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.accessToken = try container.decode(String.self, forKey: .accessToken)
    self.tokenType = try container.decode(String.self, forKey: .tokenType)
    self.expires = try Date(timeIntervalSinceNow: TimeInterval(container.decode(Int.self, forKey: .expiresIn)))
    self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    self.resourceOwner = try container.decode(String.self, forKey: .resourceOwner)
    self.scope = try container.decode(String.self, forKey: .scope)
  }
}
