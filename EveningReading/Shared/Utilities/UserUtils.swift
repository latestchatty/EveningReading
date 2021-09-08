//
// Created by Willie Zutz on 9/6/21.
//

import Foundation

class UserUtils {
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
