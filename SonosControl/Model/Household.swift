// Copyright Max von Webel. All Rights Reserved.

import Foundation

/*
 {
 "players": [
  ...
 ],
 "groups": [
  ...
 ]
 }
 */

struct Household: Decodable {
  let players: [Player]
  let groups: [Group]
  
  enum CodingKeys: String, CodingKey {
    case players = "players"
    case groups = "groups"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.players = try container.decode([Player].self, forKey: .players)
    self.groups = try container.decode([Group].self, forKey: .groups)
  }
}
