//
// Created by Willie Zutz on 9/6/21.
//

import Foundation

class UserUtils {
    static func getUserName() -> String {
        #if os(iOS)
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        #elseif os(macOS)
        let defaults = UserDefaults.standard
        let username = defaults.object(forKey: "Username") as? String ?? ""
        #endif
        return username
    }

    static func getUserPassword() -> String {
        #if os(iOS)
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")
        #elseif os(macOS)
        let defaults = UserDefaults.standard
        let password = defaults.object(forKey: "Password") as? String ?? ""
        #endif
        return password
    }
}
