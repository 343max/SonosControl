// Copyright Max von Webel. All Rights Reserved.

import XCTest

class URLParameterTests: XCTestCase {
  func testGetParameters() {
    let url = URL(string: "http://abc/def?a=b&c=d")!
    XCTAssertEqual(url.query, "a=b&c=d")
    XCTAssertEqual(url.queryItems, ["a": "b", "c": "d"])
  }
  
  func testGetWithSpace() {
    let url = URL(string: "http://abc/def?a=b%20d")!
    XCTAssertEqual(url.queryItems, ["a": "b d"])
  }
}
