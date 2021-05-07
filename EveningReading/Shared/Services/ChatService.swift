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

struct ChatLols: Hashable, Codable, Comparable {
    var tag: String
    var count: Int
    
    static func <(lhs: ChatLols, rhs: ChatLols) -> Bool {
        return lhs.tag < rhs.tag
    }
}

class ChatService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func getChat(handler: @escaping (Result<[ChatThread], Error>) -> Void) {
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/v2/getChatty")
            else { preconditionFailure("Can't create url components...") }

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let response = try self?.decoder.decode(Chat.self, from: data)
                    handler(.success(response?.threads ?? []))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}

class ChatStore: ObservableObject {
    
    private let service: ChatService
    init(service: ChatService) {
        self.service = service
    }

    @Published var threads: [ChatThread] = []
    
    @Published var activeThreadId: Int = 0
    
    @Published var scrollTargetChat: Int?
    @Published var scrollTargetChatTop: Int?
    @Published var scrollTargetThread: Int?
    @Published var scrollTargetThreadTop: Int?

    @Published var loadingChat: Bool = false {
        didSet {
            if oldValue == false && loadingChat == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.loadingChat = false
                }
            }
        }
    }
    
    @Published var loadingThread: Bool = false {
        didSet {
            if oldValue == false && loadingThread == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.loadingThread = false
                }
            }
        }
    }

    func getChat() {
        self.threads = []
        service.getChat() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let threads):
                    self?.threads = threads
                case .failure:
                    self?.threads = []
                }
            }
        }
    }
    
}
