//
//  WatchService.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 3/30/23.
//

import Combine
import Foundation
import WatchConnectivity

final class WatchService: NSObject, ObservableObject {
    static let shared = WatchService()
    @Published var username: String = ""

    override private init() {
        super.init()
        
        #if !os(watchOS)
        guard WCSession.isSupported() else {
            return
        }
        #endif
        
        WCSession.default.delegate = self
        
        WCSession.default.activate()
    }
    
    public func sendUsername() {
        print("sendUsername()")
        guard WCSession.default.activationState == .activated else {
            print("!activationState")
            return
        }
        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            print("!isCompanionAppInstalled")
            return
        }
        #else
        guard WCSession.default.isWatchAppInstalled else {
            print("!isWatchAppInstalled")
            return
        }
        #endif
        if let username = KeychainWrapper.standard.string(forKey: "Username") {
            let lowercased = username.lowercased()
            print("Sending username \(lowercased)")
            WCSession.default.sendMessage(["Username": lowercased], replyHandler: nil) { error in
                print(error.localizedDescription)
            }
            //WCSession.default.transferUserInfo(["Username": lowercased])
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("didReceiveMessage")
        DispatchQueue.main.async {
            guard let user = message["Username"] as? String else {
              return
            }
            print("Username = \(user)")
            self.username = user
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
      guard let username = userInfo["Username"] as? String else {
        return
      }
      self.username = username
    }
}
