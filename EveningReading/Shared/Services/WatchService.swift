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
        
        print("init WatchService")
        
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
            print("log: !activationState")
            return "Watch App Not Active"
        }
        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            print("log: !isCompanionAppInstalled")
            return "Watch App Not Installed"
        }
        #else
        guard WCSession.default.isWatchAppInstalled else {
            print("log: !isWatchAppInstalled")
            return "Watch App Not Installed"
        }
        #endif
        if let username = KeychainWrapper.standard.string(forKey: "Username") {
            let lowercased = username.lowercased()
            print("log: Sending username \(lowercased)")
            //WCSession.default.sendMessage(["Username": lowercased], replyHandler: nil) { error in
            //    print("log: watcherr \(error.localizedDescription)")
            //}
            WCSession.default.sendMessage(["Username": lowercased]) { msg in
                print("log: Success \(msg)")
                self.success = true
            } errorHandler: { Error in
                print("log: Fail \(Error.localizedDescription)")
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
        print("log: didReceiveMessage 1")
        DispatchQueue.main.async {
            guard let user = message["Username"] as? String else {
              return
            }
            print("log: Username = \(user)")
            self.plainTextUsername = user            
            replyHandler(["Success": true] as [String: Any])
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("log: didReceiveMessage 2")
        DispatchQueue.main.async {
            guard let user = message["Username"] as? String else {
              return
            }
            print("log: Username = \(user)")
            self.plainTextUsername = user
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("log: didReceiveUserInfo")
        guard let username = userInfo["Username"] as? String else {
            return
        }
        self.plainTextUsername = username
    }
}
