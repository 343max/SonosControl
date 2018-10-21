// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct Keychain {
  let tag: Data
  
  init(tag: String) {
    self.tag = tag.data(using: .utf8)!
  }
}
