//
//  AppSessionStore.swift
//  EveningReading
//
//  Created by Chris Hodge on 4/30/21.
//

import Foundation

class AppSessionStore : ObservableObject {
    @Published var showingHomeScreen = true
    @Published var showingChatView = false
    @Published var showingInboxView = false
    @Published var showingSearchView = false
    @Published var showingTagsView = false
    @Published var showingSettingsView = false
    
    private let service: AuthService
    init(service: AuthService) {
        self.service = service
        loadDefaults()
    }
    
    // Preferences
    @Published var displayPostAuthor: Bool = true {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(displayPostAuthor, forKey: "DisplayPostAuthor")
        }
    }
    @Published var abbreviateThreads: Bool = true {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(abbreviateThreads, forKey: "AbbreviateThreads")
        }
    }
    @Published var threadNavigation: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(threadNavigation, forKey: "ThreadNavigation")
        }
    }
    
    // Category Filters
    @Published var threadFilters: [String] = ["informative", "ontopic"]
    @Published var showInformative: Bool = true {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(showInformative, forKey: "ShowInformative")
            if self.showInformative && !self.threadFilters.contains("informative") {
                self.threadFilters.append("informative")
            } else if !self.showInformative {
                self.threadFilters = self.threadFilters.filter { $0 != "informative" }
            }
        }
    }
    @Published var showOffTopic: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(showOffTopic, forKey: "ShowOffTopic")
            if self.showOffTopic && !self.threadFilters.contains("offtopic") {
                self.threadFilters.append("offtopic")
            } else if !self.showOffTopic {
                self.threadFilters = self.threadFilters.filter { $0 != "offtopic" }
            }
        }
    }
    @Published var showPolitical: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(showPolitical, forKey: "ShowPolitical")
            if self.showPolitical && !self.threadFilters.contains("political") {
                self.threadFilters.append("political")
            } else if !self.showPolitical {
                self.threadFilters = self.threadFilters.filter { $0 != "political" }
            }
        }
    }
    @Published var showStupid: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(showStupid, forKey: "ShowStupid")
            if self.showStupid && !self.threadFilters.contains("stupid") {
                self.threadFilters.append("stupid")
            } else if !self.showStupid {
                self.threadFilters = self.threadFilters.filter { $0 != "stupid" }
            }
        }
    }
    @Published var showNWS: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(showNWS, forKey: "ShowNWS")
            if self.showNWS && !self.threadFilters.contains("nws") {
                self.threadFilters.append("nws")
            } else if !self.showNWS {
                self.threadFilters = self.threadFilters.filter { $0 != "nws" }
            }
        }
    }    
    
    // Collapsed
    @Published var collapsedThreads: [Int] = [0] {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(collapsedThreads, forKey: "CollapsedThreads")
        }
    }
    
    // Auth
    @Published var signInUsername = ""
    @Published var signInPassword = ""
    @Published var showingSignInWarning = false
    @Published var isAuthenticating: Bool = false
    @Published var isSignedIn: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(isSignedIn, forKey: "IsSignedIn")
            if !isSignedIn {
                self.signInUsername = ""
                self.signInPassword = ""
                _ = KeychainWrapper.standard.removeObject(forKey: "Username")
                _ = KeychainWrapper.standard.removeObject(forKey: "Password")
            }
        }
    }
    
    func loadDefaults() {
        // Preferences
        let defaults = UserDefaults.standard
        self.displayPostAuthor = defaults.object(forKey: "DisplayPostAuthor") as? Bool ?? true
        self.abbreviateThreads = defaults.object(forKey: "AbbreviateThreads") as? Bool ?? true
        self.threadNavigation = defaults.object(forKey: "ThreadNavigation") as? Bool ?? false
    
        // Filters
        self.threadFilters = defaults.object(forKey: "ThreadFilters") as? [String] ?? ["informative", "ontopic"]
        self.showInformative = defaults.object(forKey: "ShowInformative") as? Bool ?? true
        self.showOffTopic = defaults.object(forKey: "ShowOffTopic") as? Bool ?? false
        self.showPolitical = defaults.object(forKey: "ShowPolitical") as? Bool ?? false
        self.showStupid = defaults.object(forKey: "ShowStupid") as? Bool ?? false
        self.showNWS = defaults.object(forKey: "ShowNWS") as? Bool ?? false
        
        // Collapsed
        self.collapsedThreads = defaults.object(forKey: "CollapsedThreads") as? [Int] ?? [0]
        
        // Auth
        self.isSignedIn = defaults.object(forKey: "IsSignedIn") as? Bool ?? false
    }
    
    func resetNavigation() {
        self.showingChatView = false
        self.showingInboxView = false
        self.showingSearchView = false
        self.showingTagsView = false
        self.showingSettingsView = false
    }
    
    func clearAuth() {
        _ = KeychainWrapper.standard.removeObject(forKey: "Username")
        _ = KeychainWrapper.standard.removeObject(forKey: "Password")
        self.isSignedIn = false
        self.showingSignInWarning = true
    }
    
    func authenticate() {
        self.isAuthenticating = true
        service.auth(username: self.signInUsername, password: self.signInPassword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let authSuccess):
                    if authSuccess {
                        let didSaveUser: Bool = KeychainWrapper.standard.set(self?.signInUsername ?? "", forKey: "Username")
                        let didSavePassword: Bool = KeychainWrapper.standard.set(self?.signInPassword ?? "", forKey: "Password")
                        if didSaveUser && didSavePassword {
                            self?.isSignedIn = true
                        } else {
                            self?.clearAuth()
                        }
                    } else {
                        self?.clearAuth()
                    }
                case .failure:
                    self?.clearAuth()
                }
                self?.isAuthenticating = false
            }
        }
    }
}
