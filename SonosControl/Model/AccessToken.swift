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

struct AccessToken: Codable {
  let accessToken: String
  let tokenType: String
  let expires: Date
  let refreshToken: String
  let scope: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case expires = "expires"
    case refreshToken = "refresh_token"
    case scope = "scope"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.accessToken = try container.decode(String.self, forKey: .accessToken)
    self.tokenType = try container.decode(String.self, forKey: .tokenType)
    if container.contains(.expiresIn) {
      self.expires = try Date(timeIntervalSinceNow: TimeInterval(container.decode(Float.self, forKey: .expiresIn)))
    } else {
      self.expires = try Date(timeIntervalSince1970: TimeInterval(container.decode(Float.self, forKey: .expires)))
    }
    self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    self.scope = try container.decode(String.self, forKey: .scope)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.accessToken, forKey: .accessToken)
    try container.encode(self.tokenType, forKey: .tokenType)
    try container.encode(self.expires.timeIntervalSince1970, forKey: .expires)
    try container.encode(self.refreshToken, forKey: .refreshToken)
    try container.encode(self.scope, forKey: .scope)
  }
}

extension Keychain {
  private static let accessTokenTag = "de.343max.SonosController.accessToken"
  static func getAccessToken() throws -> AccessToken? {
    return try get(tag: accessTokenTag, type: AccessToken.self)
  }

  static func set(accessToken: AccessToken) throws {
    try set(tag: accessTokenTag, value: accessToken)
  }
}
