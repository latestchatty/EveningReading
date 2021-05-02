//
//  AppSessionStore.swift
//  EveningReading
//
//  Created by Chris Hodge on 4/30/21.
//

import Foundation

class AppSessionStore : ObservableObject {
    @Published var showingHomeScreen = true
    @Published var showingArticlesView = false
    @Published var showingChatView = false
    @Published var showingMessagesView = false
    @Published var showingSearchView = false
    @Published var showingTagsView = false
    @Published var showingSettingsView = false
    
    init() {
        
    }
    
    func resetNavigation() {
        self.showingArticlesView = false
        self.showingChatView = false
        self.showingMessagesView = false
        self.showingSearchView = false
        self.showingTagsView = false
        self.showingSettingsView = false
    }
}
