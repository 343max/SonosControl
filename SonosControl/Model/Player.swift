// Copyright Max von Webel. All Rights Reserved.

import Foundation

/*

 {
 "id": "RINCON_7828CA1D4E0201400",
 "name": "Wohnzimmer",
 "websocketUrl": "wss:\/\/192.168.0.56:1443\/websocket\/api",
 "restUrl": "https:\/\/192.168.0.56:1443\/api",
 "softwareVersion": "46.3-57250",
 "deviceIds": ["RINCON_7828CA1D4E0201400"],
 "apiVersion": "1.8.0",
 "minApiVersion": "1.1.0",
 "capabilities": ["PLAYBACK", "CLOUD", "AIRPLAY"]
 }

 */

struct Player: Decodable {
  enum Capabilities: String, Decodable {
    // https://developer.sonos.com/reference/control-api/groups/groups/#capabilities
    case playback =  "PLAYBACK"
    case cloud = "CLOUD"
    case homeTheaterSource = "HT_PLAYBACK"
    case homeTheaterControl = "HT_POWER_STATE"
    case airplay = "AIRPLAY"
    case lineIn = "LINE_IN"
    case audioClipNotifications = "AUDIO_CLIP"
  }

  let id: String
  let name: String
  let websocketUrl: URL
  let restUrl: URL
  let deviceIds: [String]
  let apiVersion: String
  let minApiVersion: String
  let capabilities: [Capabilities]

  enum CodingKeys: String, CodingKey {
    case name
    case websocketUrl
    case restUrl
    case deviceIds
    case id
    case apiVersion
    case minApiVersion
    case capabilities
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.websocketUrl = try URL(string: container.decode(String.self, forKey: .websocketUrl))!
    self.restUrl = try URL(string: container.decode(String.self, forKey: .restUrl))!
    self.deviceIds = try container.decode([String].self, forKey: .deviceIds)
    self.apiVersion = try container.decode(String.self, forKey: .apiVersion)
    self.minApiVersion = try container.decode(String.self, forKey: .minApiVersion)
    self.capabilities = try container.decode([Capabilities].self, forKey: .capabilities)
  }
}
