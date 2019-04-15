// Copyright Max von Webel. All Rights Reserved.

import Foundation

enum HTTPMethod: String {
  case GET
  case POST
}

protocol NetworkingClient {
  typealias ParameterDict = [String: String]

  func send(request: URLRequest, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
  func request(_ method: HTTPMethod, _ path: String, parameter: ParameterDict?, body: Data?) -> URLRequest
}

extension NetworkingClient {
  func send<T>(request: URLRequest, type: T.Type) -> Promise<T> where T: Decodable {
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
          promise.throw(error: error)
          print(error)
        }
      }
    })
  }
}
