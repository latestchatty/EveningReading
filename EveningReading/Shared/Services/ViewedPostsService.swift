//
//  ViewedPostsService.swift
//  EveningReading (iOS)
//
//  Created by Willie Zutz on 8/26/21.
//

import Foundation

class CloudSetting {
    static func getCloudSetting<T>(settingName: String, defaultValue: T) -> T {
        #if os(iOS)
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        #elseif os(macOS)
        let defaults = UserDefaults.standard
        let username = defaults.object(forKey: "Username") as? String ?? ""
        #endif
        
        if username == "" { return defaultValue }
        
        guard
            var urlComponents = URLComponents(string: "https://winchatty.com/v2/clientData/getClientData")
            else { preconditionFailure("Can't create url components...") }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "client", value: settingName)
        ]
        
        return defaultValue
    }
}

class ViewedPostsService {
    func getViewedPosts() -> Set<Int> {
        return CloudSetting.getCloudSetting(settingName: "werdSeenPosts", defaultValue: [])
    }
}

class ViewedPostsStore: ObservableObject {
    private let service: ViewedPostsService
    init(service: ViewedPostsService) {
        self.service = service
    }
    
    @Published var viewedPosts: Set<Int> = []
    
    public func markPostViewed(postId: Int) {
        self.viewedPosts.insert(postId)
    }
    
    public func isPostViewed(postId: Int) -> Bool {
        return self.viewedPosts.contains(postId)
    }
}
