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

class Sonos: NetworkingClient {
  let baseURL = "https://api.sonos.com/"

  func sendRequest(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, body: Data?, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
    var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
    components.path += path
    components.queryItems = parameter.map { URLQueryItem(name: $0, value: $1) }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method.rawValue
    request.httpBody = body
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      let httpResponse = response as! HTTPURLResponse?
      callback(data, httpResponse, error)
    }
    
    task.resume()
  }
}

extension Sonos {
  func loginURL(state: String, redirectUri: URL) -> URL {
    return URLComponents(string: baseURL + "login/v3/oauth", queryItems: [
      "client_id": clientKey,
      "response_type": "code",
      "state": state,
      "scope": "playback-control-all",
      "redirect_uri": redirectUri.absoluteString
      ])!.url!
  }
}

extension Sonos {
  var clientKey: String {
    get {
      guard let url = Bundle.main.url(forResource: "Key", withExtension: "plist") else {
        assert(false, "Please create Key.plist with a SonosAPIKey string value")
      }
      let dict = NSDictionary(contentsOf: url)!
      return dict["SonosAPIKey"] as! String
    }
  }
}

extension Sonos {
  static func authorizationCode(from url:URL) -> String {
    return url.queryItems["code"]!
  }
}
