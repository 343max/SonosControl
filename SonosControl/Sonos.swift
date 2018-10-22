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
  struct Configuration {
    let redirectURL: URL
    let clientKey: String
    let clientSectret: String
  }
  
  let baseURL = "https://api.sonos.com/"
  let configuration: Configuration
  var accessToken: AccessToken?
  
  init(configuration: Configuration) {
    self.configuration = configuration
  }
  
  func send(request: URLRequest, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      let httpResponse = response as! HTTPURLResponse?
      callback(data, httpResponse, error)
    }
    
    task.resume()
  }
  
  func request(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, body: Data?) -> URLRequest {
    var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
    components.path += path
    components.queryItems = parameter.map { URLQueryItem(name: $0, value: $1) }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method.rawValue
    request.httpBody = body
    return request
  }
}

extension Sonos {
  func loginURL(state: String) -> URL {
    return URLComponents(string: baseURL + "login/v3/oauth", queryItems: [
      "client_id": configuration.clientKey,
      "response_type": "code",
      "state": state,
      "scope": "playback-control-all",
      "redirect_uri": configuration.redirectURL.absoluteString
      ])!.url!
  }
  
  func createAccessToken(authorizationCode: String) -> Promise<AccessToken> {
    let queyItems = [
      "grant_type": "authorization_code",
      "code": authorizationCode,
      "redirect_uri": configuration.redirectURL.absoluteString
    ]
    var request = self.request(.POST, "login/v3/oauth/access", [:], body: queyItems.queryString.data(using: .utf8))
    let authorization = "\(configuration.clientKey):\(configuration.clientSectret)"
    request.setValue("Basic " + authorization.data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
    return send(request: request, type: AccessToken.self)
  }
}

extension Sonos {
  static func authorizationCode(from url:URL) -> String {
    return url.queryItems["code"]!
  }
}
