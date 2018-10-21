// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
  var authenticationSession: ASWebAuthenticationSession?

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let sonos = Sonos()
    
    let url = sonos.loginURL(state: "hello", redirectUri: URL(string: "https://sonoscontrol.343max.de/authorized.php")!)
    let authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "de.343max.sonoscontrol") { (url, error) in
      guard let url = url else {
        return
      }
      
      let authorizationCode = Sonos.authorizationCode(from: url)
    }
    authenticationSession.start()
    self.authenticationSession = authenticationSession
  }

}

