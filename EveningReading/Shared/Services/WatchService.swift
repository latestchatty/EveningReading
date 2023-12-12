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
    @Published var plainTextUsername: String = "" {
        didSet {
            UserDefaults.standard.set(plainTextUsername, forKey: "PlainTextUsername")
        }
    }
    @Published var success = false

    override private init() {
        super.init()
        
        let defaults = UserDefaults.standard
        self.plainTextUsername = defaults.object(forKey: "PlainTextUsername") as? String ?? ""
        
        #if !os(watchOS)
        guard WCSession.isSupported() else {
            return
        }
        #endif
        
        WCSession.default.delegate = self
        
        WCSession.default.activate()
    }
    
    public func sendUsername() -> String {
        print("sendUsername()")
        guard WCSession.default.activationState == .activated else {
            return "Watch App Not Active"
        }
        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            return "Watch App Not Installed"
        }
        #else
        guard WCSession.default.isWatchAppInstalled else {
            return "Watch App Not Installed"
        }
        #endif
        if let username = KeychainWrapper.standard.string(forKey: "Username") {
            let lowercased = username.lowercased()
            WCSession.default.sendMessage(["Username": lowercased]) { msg in
                self.success = true
            } errorHandler: { Error in
                self.success = false
            }
            if success {
                return "Successfully Synced user \(username)..."
            } else {
                return "Syncing..."
            }
        }
        return "Syncing..."
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            guard let user = message["Username"] as? String else {
              return
            }
            self.plainTextUsername = user
            replyHandler(["Success": true] as [String: Any])
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            guard let user = message["Username"] as? String else {
              return
            }
            self.plainTextUsername = user
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let username = userInfo["Username"] as? String else {
            return
        }
        self.plainTextUsername = username
    }
}
