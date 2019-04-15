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

  let authentificationBaseURL = "https://api.sonos.com/"
  let baseURL = "https://api.ws.sonos.com/control/api/v1/"
  let configuration: Configuration
  var accessToken: AccessToken?

  init(configuration: Configuration) {
    self.configuration = configuration
  }

  func send(request: URLRequest, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      let httpResponse = response as! HTTPURLResponse // swiftlint:disable:this force_cast
      callback(data, httpResponse, error)
    }

    task.resume()
  }

  func request(_ method: HTTPMethod, _ path: String, parameter: ParameterDict? = nil, body: Data? = nil) -> URLRequest {
    var components = URLComponents(url: URL(string: baseURL)!, resolvingAgainstBaseURL: false)!
    components.path += path
    if let parameter = parameter {
      components.queryItems = parameter.map { URLQueryItem(name: $0, value: $1) }
    }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method.rawValue
    request.httpBody = body
    return request
  }
}

extension Sonos {
  enum AuthorizationError: Error {
    case unauthorized
  }

  func loginURL(state: String) -> URL {
    return URLComponents(string: authentificationBaseURL + "login/v3/oauth", queryItems: [
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
    var request = URLRequest(url: URL(string: authentificationBaseURL + "login/v3/oauth/access")!)
    request.httpMethod = "POST"
    request.httpBody = queyItems.queryString.data(using: .utf8)
    let authorization = "\(configuration.clientKey):\(configuration.clientSectret)"
    request.setValue("Basic " + authorization.data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
    return send(request: request, type: AccessToken.self)
  }

  func authorized(request: URLRequest) throws -> URLRequest {
    guard let token = self.accessToken else {
      throw AuthorizationError.unauthorized
    }

    var request = request
    request.setValue("Bearer " + token.accessToken, forHTTPHeaderField: "Authorization")
    request.setValue(configuration.clientKey, forHTTPHeaderField: "X-Sonos-Api-Key")
    return request
  }
}

extension Sonos {
  private struct Households: Decodable {
    struct HouseholdId: Decodable {
      let id: String
    }
    let households: [HouseholdId]
  }

  func households() throws -> Promise<[String]> {
    return try send(request: authorized(request: request(.GET, "households")), type: Households.self).map({ (household) -> [String] in
      return household.households.map { $0.id }
    })
  }

  func household(id: String) throws -> Promise<Household> {
    return try send(request: authorized(request: request(.GET, "households/\(id)/groups")), type: Household.self)
  }
}

extension Sonos {
  static func authorizationCode(from url: URL) -> String {
    return url.queryItems["code"]!
  }
}
