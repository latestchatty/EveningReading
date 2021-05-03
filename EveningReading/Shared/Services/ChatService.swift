//
//  ChatService.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import Foundation

struct Chat: Hashable, Codable {
    var threads: [ChatThread]
}

struct ChatThread: Hashable, Codable {
    var threadId: Int
    var posts: [ChatPosts]
}

struct ChatPosts: Hashable, Codable {
    var id: Int
    var threadId: Int
    var parentId: Int
    var author: String
    var category: String
    var date: String
    var body: String
    var lols: [ChatLols]
}

struct ChatLols: Hashable, Codable {
    var tag: String
    var count: Int
}

class ChatService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
}

class ChatStore: ObservableObject {
    
    private let service: ChatService
    init(service: ChatService) {
        self.service = service
    }
    
    @Published var scrollTargetChat: Int?
    @Published var scrollTargetChatTop: Int?

    @Published var loadingChat: Bool = false {
        didSet {
            if oldValue == false && loadingChat == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    self.loadingChat = false
                }
            }
        }
    }
}
