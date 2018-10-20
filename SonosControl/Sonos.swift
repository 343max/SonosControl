// Copyright Max von Webel. All Rights Reserved.

import Foundation

extension URLComponents {
  init?(string: String, queryItems: [String: String]) {
    self.init(string: string)
    self.queryItems = queryItems.compactMap({ (name, value) -> URLQueryItem in
      return URLQueryItem(name: name, value: value)
    })
  }
}

struct Sonos {
  static let baseURL = "https://api.sonos.com/"
  
  func loginURL(clientId: String, state: String, redirectUri: URL) -> URLComponents {
    return URLComponents(string: Sonos.baseURL + "login/v3/oauth", queryItems: [
      "client_id": clientId,
      "response_type": "code",
      "state": state,
      "scope": "playback-control-all",
      "redirect_uri": redirectUri.absoluteString
      ])!
  }
}
