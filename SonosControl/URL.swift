// Copyright Max von Webel. All Rights Reserved.

import Foundation

extension URL {
  public var queryItems: [String: String] {
    get {
      guard let query = query else {
        return [:]
      }
      
      return query.split(separator: "&").reduce([:], { (letDict, string) -> [String: String] in
        let pair = string.split(separator: "=")
        assert(pair.count == 2)
        
        var dict = letDict
        dict[String(pair[0]).removingPercentEncoding!] = String(pair[1]).removingPercentEncoding!
        return dict
      })
    }
  }
}

extension Dictionary where Key == String, Value == String {
  var queryString: String {
    get {
      return self.reduce(into: [] as [String], { (array, tupel) in
        let (key, value) = tupel
        array.append("\(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)=\(value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
      }).joined(separator: "&")
    }
  }
}
