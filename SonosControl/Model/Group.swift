// Copyright Max von Webel. All Rights Reserved.

import Foundation

/*

 {
 "playerIds": [
 "RINCON_7DQQGH13GH4Q12345"
 ],
 "playbackState": "PLAYBACK_STATE_IDLE",
 "coordinatorId": "RINCON_7DQQGH13GH4Q12345",
 "id": "RINCON_7DQQGH13GH4Q12345:218",
 "name": "p5"
 }

*/

enum PlaybackState: String {
  case buffering = "PLAYBACK_STATE_BUFFERING"
  case idle = "PLAYBACK_STATE_IDLE"
  case paused = "PLAYBACK_STATE_PAUSED"
  case playing = "PLAYBACK_STATE_PLAYING"
}

struct Group: Decodable {
  let id: String
  let name: String
  let playbackState: PlaybackState
  let coordinatorId: String
  let playerIds: [String]

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case playbackState
    case coordinatorId
    case playerIds
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.playbackState = try PlaybackState(rawValue: container.decode(String.self, forKey: .playbackState))!
    self.coordinatorId = try container.decode(String.self, forKey: .coordinatorId)
    self.playerIds = try container.decode([String].self, forKey: .playerIds)
  }
}
