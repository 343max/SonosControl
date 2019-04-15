// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AuthenticationServices

extension Sonos.Configuration {
  static func appConfig() -> Sonos.Configuration {
    guard let url = Bundle.main.url(forResource: "Key", withExtension: "plist") else {
      assert(false, "Please create Key.plist with a SonosAPIKey and SonosAPISecret string value")
    }
    let dict = NSDictionary(contentsOf: url)!
    return Sonos.Configuration(redirectURL: URL(string: "https://sonoscontrol.343max.de/authorized.php")!,
                               clientKey: dict["SonosAPIKey"] as! String,  // swiftlint:disable:this force_cast
                               clientSectret: dict["SonosAPISecret"] as! String)  // swiftlint:disable:this force_cast
  }
}

class ViewController: UIViewController {
  var authenticationSession: ASWebAuthenticationSession?
  var sonos: Sonos!

  override func viewDidLoad() {
    sonos = Sonos(configuration: .appConfig())

    if let accessToken = try! Keychain.getAccessToken() {  // swiftlint:disable:this force_try
      sonos.accessToken = accessToken
      try! loadHousehold() // swiftlint:disable:this force_try
    } else {
      let url = sonos.loginURL(state: "hello")
      let authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "de.343max.sonoscontrol") { (url, _) in
        guard let url = url else {
          return
        }

        let authorizationCode = Sonos.authorizationCode(from: url)
        self.sonos.createAccessToken(authorizationCode: authorizationCode).then {
          try! Keychain.set(accessToken: $0) // swiftlint:disable:this force_try
          self.sonos.accessToken = $0
          try! self.loadHousehold() // swiftlint:disable:this force_try
        }
      }
      authenticationSession.start()
      self.authenticationSession = authenticationSession
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  func loadHousehold() throws {
    try sonos.households().then {
      print("households: \($0)")
    }.then {
      $0.forEach({ (id) in
        try! self.sonos.household(id: id).then { // swiftlint:disable:this force_try
          print("household: \($0)")
        }
      })
    }
  }
}
