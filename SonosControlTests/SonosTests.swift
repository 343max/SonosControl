// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import SonosControl

class SonosTests: XCTestCase {
  func testAuthorizationCodeFromURL() {
    let url = URL(string: "de.343max.sonoscontrol://redirect//authorized.php?state=hello&code=eee34eb8-1df1-4279-a63c-081a2ed579b2")!
    let authorizationCode = Sonos.authorizationCode(from: url)
    XCTAssertEqual("eee34eb8-1df1-4279-a63c-081a2ed579b2", authorizationCode)
  }
}
