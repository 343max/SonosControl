// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import SonosControl

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

class DictionaryQueryItems: XCTestCase {
  func testEmptyDict() {
    let dict: [String: String] = [:]
    let queryString = dict.queryString
    XCTAssertEqual(queryString, "")
  }

  func testSimpleDict() {
    let queryString = [
      "a": "b"
    ].queryString
    XCTAssertEqual(queryString, "a=b")
  }

  func testLongerDict() {
    let queryString = [
      "a": "b",
      "c": "d"
    ].queryString
    XCTAssertEqual(queryString, "a=b&c=d")
  }

  func testSpecialChars() {
    let queryString = [
      "a": "b c"
    ].queryString
    XCTAssertEqual(queryString, "a=b%20c")
  }
}
