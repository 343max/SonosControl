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
                               clientKey: dict["SonosAPIKey"] as! String,
                               clientSectret: dict["SonosAPISecret"] as! String)
  }
}

class ViewController: UIViewController {
  var authenticationSession: ASWebAuthenticationSession?
  var sonos: Sonos!
  
  override func viewDidLoad() {
    sonos = Sonos(configuration: .appConfig())
    
    if let accessToken = try! Keychain.getAccessToken() {
      sonos.accessToken = accessToken
      loadHousehold()
    } else {
      let url = sonos.loginURL(state: "hello")
      let authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "de.343max.sonoscontrol") { (url, error) in
        guard let url = url else {
          return
        }
        
        let authorizationCode = Sonos.authorizationCode(from: url)
        self.sonos.createAccessToken(authorizationCode: authorizationCode).then {
          try! Keychain.set(accessToken: $0)
          self.sonos.accessToken = $0
          self.loadHousehold()
        }
      }
      authenticationSession.start()
      self.authenticationSession = authenticationSession
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func loadHousehold() {
    try! sonos.households().then {
      print("households: \($0)")
      }.then {
        $0.forEach({ (id) in
          try! self.sonos.household(id: id).then {
            print("household: \($0)")
          }
        })
    }
  }
}

