//
//  UserHelper.swift
//  EveningReading (macOS)
//
//  Created by Chris Hodge on 10/26/21.
//

import Foundation

class UserHelper {
    static func getUserName() -> String {
        #if os(macOS)
        let defaults = UserDefaults.standard
        let username = defaults.object(forKey: "Username") as? String ?? ""
        #else
        let username = KeychainWrapper.standard.string(forKey: "Username") ?? ""
        #endif
        return username
    }

    static func getUserPassword() -> String {
        #if os(macOS)
        let defaults = UserDefaults.standard
        let password = defaults.object(forKey: "Password") as? String ?? ""
        #else
        let password = KeychainWrapper.standard.string(forKey: "Password") ?? ""
        #endif
        return password
    }
}
