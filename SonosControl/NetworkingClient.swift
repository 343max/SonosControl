// Copyright Max von Webel. All Rights Reserved.

import Foundation

enum HTTPMethod : String {
  case GET = "GET"
  case POST = "POST"
}

protocol NetworkingClient {
  typealias ParameterDict = [String: String]
  func sendRequest(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, body: Data?, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}

extension NetworkingClient {
  func sendRequest<T>(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, body: Data? = nil, type: T.Type) -> Promise<T> where T : Decodable {
    return Promise<T>({ (completion, promise) in
      sendRequest(method, path, parameter, body: body) { (data, _, error) in
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
    sendRequest(.GET, path, parameter, body: nil, callback: callback)
  }
  
  func GET<T>(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, type: T.Type) -> Promise<T> where T : Decodable {
    return sendRequest(.GET, path, parameter, type: type)
  }
  
  func POST<T>(_ path: String, queryItems: ParameterDict = [:], bodyItems: ParameterDict = [:], type: T.Type) -> Promise<T> where T: Decodable {
    return sendRequest(.POST, path, queryItems, body: bodyItems.queryString.data(using: .utf8), type: type)
  }
}
