//
//  AppService.swift
//  EveningReading
//
//  Created by Chris Hodge on 4/30/21.
//

import Foundation
import SwiftUI
import Combine

class AppService : ObservableObject {
    // Init
    init() {
        loadDefaults()
        loadWords()
    }
    
    // Sheet fix for iOS 17
    @Published var showingComposeSheet = false
    @Published var showingSafariSheet = false
    
    // Navigation
    @Published var showingHomeScreen = true
    @Published var showingChatView = false
    @Published var showingInboxView = false
    @Published var showingSearchView = false
    @Published var showingTagsView = false
    @Published var showingSettingsView = false
    @Published var showingPushNotificationThread = false
    
    // Links and notifications open posts
    @Published var showingPost = false
    @Published var showingPostId = 0
    @Published var showingPostWithId: [Int : Bool] = [:]
    
    // Report user for post
    @Published var showingReportUserSheet: Bool = false
    @Published var reportAuthorName = ""
    @Published var reportAuthorForPostId = 0
    
    // Preferences
    @Published var displayPostAuthor: Bool = true {
        didSet {
            UserDefaults.standard.set(displayPostAuthor, forKey: "DisplayPostAuthor")
        }
    }
    @Published var abbreviateThreads: Bool = true {
        didSet {
            UserDefaults.standard.set(abbreviateThreads, forKey: "AbbreviateThreads")
        }
    }
    @Published var threadNavigation: Bool = false {
        didSet {
            UserDefaults.standard.set(threadNavigation, forKey: "ThreadNavigation")            
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .phone {
                let navigationLocation = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 120)
                self.threadNavigationLocationX = navigationLocation.x
                self.threadNavigationLocationY = navigationLocation.y
            }
            #endif
        }
    }
    @Published var isDarkMode: Bool = true {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "IsDarkMode")
        }
    }
    @Published var useYoutubeApp: Bool = false {
        didSet {
            UserDefaults.standard.set(useYoutubeApp, forKey: "UseYoutubeApp")
        }
    }
    @Published var disableAnimation: Bool = false {
        didSet {
            UserDefaults.standard.set(disableAnimation, forKey: "DisableAnimation")
        }
    }
    @Published var showLinkCopyButton: Bool = false {
        didSet {
            UserDefaults.standard.set(showLinkCopyButton, forKey: "ShowLinkCopyButton")
        }
    }
    
    // Category Filters
    @Published var threadFilters: [String] = ["informative", "ontopic"]
    @Published var showInformative: Bool = true {
        didSet {
            UserDefaults.standard.set(showInformative, forKey: "ShowInformative")
            if self.showInformative && !self.threadFilters.contains("informative") {
                self.threadFilters.append("informative")
            } else if !self.showInformative {
                self.threadFilters = self.threadFilters.filter { $0 != "informative" }
            }
        }
    }
    @Published var showOffTopic: Bool = false {
        didSet {
            UserDefaults.standard.set(showOffTopic, forKey: "ShowOffTopic")
            if self.showOffTopic && !self.threadFilters.contains("tangent") {
                self.threadFilters.append("tangent")
            } else if !self.showOffTopic {
                self.threadFilters = self.threadFilters.filter { $0 != "tangent" }
            }
        }
    }
    @Published var showPolitical: Bool = false {
        didSet {
            UserDefaults.standard.set(showPolitical, forKey: "ShowPolitical")
            if self.showPolitical && !self.threadFilters.contains("political") {
                self.threadFilters.append("political")
            } else if !self.showPolitical {
                self.threadFilters = self.threadFilters.filter { $0 != "political" }
            }
        }
    }
    @Published var showStupid: Bool = false {
        didSet {
            UserDefaults.standard.set(showStupid, forKey: "ShowStupid")
            if self.showStupid && !self.threadFilters.contains("stupid") {
                self.threadFilters.append("stupid")
            } else if !self.showStupid {
                self.threadFilters = self.threadFilters.filter { $0 != "stupid" }
            }
        }
    }
    @Published var showNWS: Bool = false {
        didSet {
            UserDefaults.standard.set(showNWS, forKey: "ShowNWS")
            if self.showNWS && !self.threadFilters.contains("nws") {
                self.threadFilters.append("nws")
            } else if !self.showNWS {
                self.threadFilters = self.threadFilters.filter { $0 != "nws" }
            }
        }
    }
    @Published var hideBadWords: Bool = true {
        didSet {
            UserDefaults.standard.set(hideBadWords, forKey: "HideBadWords")
            if self.hideBadWords {
                badWords = defaultBadWords
            } else if !self.hideBadWords {
                badWords = []
            }
        }
    }
    
    // Language Filters
    @Published var defaultBadWords: [String] = []
    @Published var badWords: [String] = []
    
    // Collapsed
    @Published var collapsedThreads: [Int] = [0] {
        didSet {
            UserDefaults.standard.set(collapsedThreads, forKey: "CollapsedThreads")
        }
    }
    
    // Authors
    @Published var blockedAuthors: [String] = [""] {
        didSet {
            UserDefaults.standard.set(blockedAuthors, forKey: "BlockedAuthors")
        }
    }

    @Published var favoriteAuthors: [String] = [""] {
        didSet {
            UserDefaults.standard.set(favoriteAuthors, forKey: "FavoriteAuthors")
        }
    }
    
    // Thread Navigation
    #if os(iOS)
    @Published var threadNavigationLocationX: CGFloat = UIScreen.main.bounds.width - 50 {
        didSet {
            UserDefaults.standard.set(threadNavigationLocationX, forKey: "PaginateLocationX")
        }
    }
    @Published var threadNavigationLocationY: CGFloat = UIScreen.main.bounds.height - 120 {
        didSet {
            UserDefaults.standard.set(threadNavigationLocationY, forKey: "PaginateLocationY")
        }
    }
    #endif
    
    // Auth
    #if os(macOS)
    @Published var username: String = "" {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(username, forKey: "Username")
        }
    }
    @Published var password: String = "" {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(password, forKey: "Password")
        }
    }
    #endif
    @Published var signInUsername = ""
    @Published var signInPassword = ""
    @Published var showingSignInWarning = false
    @Published var isAuthenticating: Bool = false
    @Published var isSignedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isSignedIn, forKey: "IsSignedIn")
            if !isSignedIn {
                self.signInUsername = ""
                self.signInPassword = ""
                #if os(iOS)
                _ = KeychainWrapper.standard.removeObject(forKey: "Username")
                _ = KeychainWrapper.standard.removeObject(forKey: "Password")
                #endif
                #if os(macOS)
                self.username = ""
                self.password = ""
                #endif
            }
        }
    }
    
    // Push Notifications
    @Published var pushNotifications = [PushNotification]()
    @Published var didRegisterForPush = false
    /*
    @Published var pushNotifications = [PushNotification]() {
        didSet {
            if let data = try? PropertyListEncoder().encode(pushNotifications) {
                UserDefaults.standard.set(data, forKey: "PushNotifications")
            }
        }
    }
    */
    
    // Search & Push
    @Published var showingShackLink: Bool = false
    @Published var shackLinkPostId: String = ""
    func setLink(postId: String) {
        shackLinkPostId = postId
        showingShackLink = true
    }
    
    func loadDefaults() {
        let defaults = UserDefaults.standard
        
        // Preferences
        self.displayPostAuthor = defaults.object(forKey: "DisplayPostAuthor") as? Bool ?? true
        self.abbreviateThreads = defaults.object(forKey: "AbbreviateThreads") as? Bool ?? true
        self.threadNavigation = defaults.object(forKey: "ThreadNavigation") as? Bool ?? false
        self.isDarkMode = defaults.object(forKey: "IsDarkMode") as? Bool ?? true
        self.useYoutubeApp = defaults.object(forKey: "UseYoutubeApp") as? Bool ?? false
        self.disableAnimation = defaults.object(forKey: "DisableAnimation") as? Bool ?? false
        
        // Filters
        self.threadFilters = defaults.object(forKey: "ThreadFilters") as? [String] ?? ["informative", "ontopic"]
        self.showInformative = defaults.object(forKey: "ShowInformative") as? Bool ?? true
        self.showOffTopic = defaults.object(forKey: "ShowOffTopic") as? Bool ?? false
        self.showPolitical = defaults.object(forKey: "ShowPolitical") as? Bool ?? false
        self.showStupid = defaults.object(forKey: "ShowStupid") as? Bool ?? false
        self.showNWS = defaults.object(forKey: "ShowNWS") as? Bool ?? false
        self.hideBadWords = defaults.object(forKey: "HideBadWords") as? Bool ?? true
        
        // Authors
        self.blockedAuthors = defaults.object(forKey: "BlockedAuthors") as? [String] ?? [""]
        self.favoriteAuthors = defaults.object(forKey: "FavoriteAuthors") as? [String] ?? [""]
        
        // Collapsed
        self.collapsedThreads = defaults.object(forKey: "CollapsedThreads") as? [Int] ?? [0]
        
        // Copy Link
        self.showLinkCopyButton = defaults.object(forKey: "ShowLinkCopyButton") as? Bool ?? false

        // Navigation
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.threadNavigationLocationX = 0
            self.threadNavigationLocationY = 0
        } else {
            self.threadNavigationLocationX = defaults.object(forKey: "PaginateLocationX") as? CGFloat ?? UIScreen.main.bounds.width - 50
            self.threadNavigationLocationY = defaults.object(forKey: "PaginateLocationY") as? CGFloat ?? UIScreen.main.bounds.height - 120
        }
        #endif
        
        // Auth
        self.isSignedIn = defaults.object(forKey: "IsSignedIn") as? Bool ?? false
        #if os(macOS)
        self.username = defaults.object(forKey: "Username") as? String ?? ""
        self.password = defaults.object(forKey: "Password") as? String ?? ""
        #endif
            
        /*
        // Reset on startup
        // ResetDarkMode
        // ResetNotifications
        let resetNotifications = defaults.object(forKey: "ResetNotifications") as? Bool ?? false
        if !resetNotifications {
            UserDefaults.standard.removeObject(forKey: "PushNotifications")
            defaults.set(true, forKey: "ResetNotifications")
        }
        */
            
        // Push Notifications
        /*
        if let data = defaults.data(forKey: "PushNotifications") {
            self.pushNotifications = try! PropertyListDecoder().decode([PushNotification].self, from: data)
        }
        */
    }
    
    func loadWords() {
        let wordsFromFile: Words = loadWordsFromFile("Words.json")
        for i in 0..<wordsFromFile.words.count {
            defaultBadWords.append(wordsFromFile.words[i].word)
        }
        badWords = defaultBadWords
    }
    
    func loadWordsFromFile<T: Decodable>(_ filename: String) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    func resetNavigation() {
        self.showingChatView = false
        self.showingInboxView = false
        self.showingSearchView = false
        self.showingTagsView = false
        self.showingSettingsView = false
        self.showingPushNotificationThread = false
    }
    
    func clearNotifications() {
        self.pushNotifications = [PushNotification]()
    }
    
    func clearAuth() {
        #if os(iOS)
        _ = KeychainWrapper.standard.removeObject(forKey: "Username")
        _ = KeychainWrapper.standard.removeObject(forKey: "Password")
        #endif
        #if os(macOS)
        self.username = ""
        self.password = ""
        #endif
        self.isSignedIn = false
        self.showingSignInWarning = true
    }
    
    func authenticate() {
        self.isAuthenticating = true
        authenticateViaAPI(username: self.signInUsername, password: self.signInPassword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let authSuccess):
                    if authSuccess {
                        #if os(iOS)
                        let didSaveUser: Bool = KeychainWrapper.standard.set(self?.signInUsername ?? "", forKey: "Username")
                        let didSavePassword: Bool = KeychainWrapper.standard.set(self?.signInPassword ?? "", forKey: "Password")
                        if didSaveUser && didSavePassword {
                            self?.isSignedIn = true
                        } else {
                            self?.clearAuth()
                        }
                        #endif
                        #if os(macOS)
                        self?.username = self?.signInUsername ?? ""
                        self?.password = self?.signInPassword ?? ""
                        self?.isSignedIn = true
                        #endif
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
    
    public func authenticateViaAPI(username: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()
        
        let loginUrl = URL(string: "https://winchatty.com/v2/verifyCredentials")!
        var components = URLComponents(url: loginUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        let query = components.url!.query
                
        var request = URLRequest(url: loginUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query!.utf8)

        session.dataTask(with: request as URLRequest) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let response = try decoder.decode(AuthResponse.self, from: data)
                    handler(.success(response.isValid))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}
