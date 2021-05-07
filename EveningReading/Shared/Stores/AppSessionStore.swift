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
    
    // Filters
    @Published var threadFilters: [String] = ["informative", "ontopic"]
    
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
    @Published var isSignedIn: Bool = false {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(isSignedIn, forKey: "IsSignedIn")
            if !isSignedIn {
                self.signInUsername = ""
                self.signInPassword = ""
            }
        }
    }
    
    
    func loadDefaults() {
            // Preferences
            let defaults = UserDefaults.standard
            self.displayPostAuthor = defaults.object(forKey: "DisplayPostAuthor") as? Bool ?? true
            self.abbreviateThreads = defaults.object(forKey: "AbbreviateThreads") as? Bool ?? true
            self.threadNavigation = defaults.object(forKey: "ThreadNavigation") as? Bool ?? false
    }
    
    func resetNavigation() {
        self.showingChatView = false
        self.showingInboxView = false
        self.showingSearchView = false
        self.showingTagsView = false
        self.showingSettingsView = false
    }
}
