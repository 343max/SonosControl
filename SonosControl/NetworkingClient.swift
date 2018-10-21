// Copyright Max von Webel. All Rights Reserved.

import Foundation

enum HTTPMethod : String {
  case GET = "GET"
  case POST = "POST"
}

protocol NetworkingClient {
  typealias ParameterDict = [String: String]

  func send(request: URLRequest, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
  func request(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, body: Data?) -> URLRequest
}

extension NetworkingClient {
  func send<T>(request: URLRequest, type: T.Type) -> Promise<T> where T : Decodable {
    return Promise<T>({ (completion, promise) in
      send(request: request) { (data, _, error) in
        guard let data = data else {
          promise.throw(error: error!)
          return
        }
        
        do {
          let result = try JSONDecoder().decode(type, from: data)
          completion(result)
        } catch {
          print(error)
        }
      }
    })
  }
}

extension NetworkingClient {
  func GET(_ path: String, _ parameter: ParameterDict, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
    send(request: request(.GET, path, parameter, body: nil), callback: callback)
  }
  
  func GET<T>(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, type: T.Type) -> Promise<T> where T : Decodable {
    return send(request: request(.GET, path, parameter, body: nil), type: type)
  }
  
  func POST<T>(_ path: String, queryItems: ParameterDict = [:], bodyItems: ParameterDict = [:], type: T.Type) -> Promise<T> where T: Decodable {
    return send(request: request(.POST, path, queryItems, body: bodyItems.queryString.data(using: .utf8)), type: type)
  }
}
