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

// Submission
struct SubmitPostResponseContainer: Hashable, Codable {
    var success: SubmitPostReponse
    var fail: SubmitPostError
}

struct SubmitPostReponse: Hashable, Codable {
    var result: String
}

struct SubmitPostError: Hashable, Codable {
    var error: Bool
    var code: String
    var message : String
}

// Search
struct SearchChat: Hashable, Codable {
    var posts: [SearchChatPosts]
}

struct SearchChatPosts: Hashable, Codable {
    var id: Int
    var threadId: Int
    var parentId: Int
    var author: String
    var authorId: Int
    var category: String
    var date: String
    var body: String
    var lols: [Int]
    var isCortex: Bool
    var isFrozen: Bool
}

// Tagging
struct RatersWrapper: Hashable, Codable {
    var raters: RatersResponse
}

struct RatersResponse: Hashable, Codable {
    var status: String
    var data: [Raters]
    var message: String
}

struct Raters: Hashable, Codable {
    var thread_id: String
    var user_ids: [String]
    var usernames: [String]
    var tag: String
}

struct TagReponse: Hashable, Codable {
    var status: String
    var data: String?
    var message: String
}

// Service for chat related functionality
class ChatService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func getChat(handler: @escaping (Result<[ChatThread], Error>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        #if os(iOS)
        sessionConfig.waitsForConnectivity = false
        sessionConfig.timeoutIntervalForResource = 5.0
        #endif
        let shortSession = URLSession(configuration: sessionConfig)
        
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/v2/getChatty")
            else { preconditionFailure("Can't create url components...") }

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        shortSession.dataTask(with: url) { [weak self] data, _, error in
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
    
    public func getThread(threadId: Int, handler: @escaping (Result<[ChatThread], Error>) -> Void) {
        guard
            var urlComponents = URLComponents(string: "https://winchatty.com/v2/getThread")
            else { preconditionFailure("Can't create url components...") }

        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: (String(threadId)))
        ]

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
    
    public func tag(postId: Int, tag: String, untag: String, handler: @escaping (Result<TagReponse, Error>) -> Void) {
        if let lolKey = Bundle.main.infoDictionary?["LOL_KEY"] as? String {
            
            let username: String? = KeychainWrapper.standard.string(forKey: "Username")
            
            guard
                var urlComponents = URLComponents(string: "https://www.shacknews.com/api2/api-index.php")
                else { preconditionFailure("Can't create url components...") }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "action2", value: "ext_create_tag_via_api"),
                URLQueryItem(name: "untag", value: untag),
                URLQueryItem(name: "secret", value: lolKey),
                URLQueryItem(name: "tag", value: tag),
                URLQueryItem(name: "user", value: username),
                URLQueryItem(name: "id", value: (String(postId)))
            ]

            guard
                let url = urlComponents.url
                else { preconditionFailure("Can't create url from url components...") }

            session.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    handler(.failure(error))
                } else {
                    do {
                        let data = data ?? Data()
                        let response = try self?.decoder.decode(TagReponse.self, from: data)
                        handler(.success(response ?? TagReponse(status: "0", data: nil, message: "")))
                    } catch {
                        handler(.failure(error))
                    }
                }
            }.resume()
            
        } else {
            
        }
    }
    
    public func submitPost(postBody: String, postId: Int, handler: @escaping (Result<SubmitPostResponseContainer, Error>) -> Void) {
        //print("returning from submitPost for post \(postId)")
        //let resp = SubmitPostResponseContainer(success: SubmitPostReponse(result: "success"), fail: SubmitPostError(error: false, code: "ERR_NONE", message: "No error."))
        //let resp = SubmitPostResponseContainer(success: SubmitPostReponse(result: "failure"), fail: SubmitPostError(error: true, code: "47", message: "test failure"))
        //handler(.success(resp))
        //return
        
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")
        
        print("post submitted to server... post \(postId)")
        
        let newPostUrl = URL(string: "https://winchatty.com/v2/postComment")!
        var components = URLComponents(url: newPostUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "parentId", value: String(postId)),
            URLQueryItem(name: "text", value: postBody)
        ]
        
        guard
            let query = components.url!.query
            else { preconditionFailure("Can't create url components...") }
        
        var request = URLRequest(url: newPostUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                handler(.failure(error!))
                return
            }
            guard let data = data else {
                handler(.failure(error!))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    var didProcessResponse = false
                    
                    do {
                        let successResponse = try self.decoder.decode(SubmitPostReponse.self, from: data)
                        let resp = SubmitPostResponseContainer(success: SubmitPostReponse(result: "success"), fail: SubmitPostError(error: false, code: "ERR_NONE", message: "No error."))
                        didProcessResponse = true
                        handler(.success(resp))
                    } catch {
                        // ChattyService submitPost - successResponse fail
                    }

                    if !didProcessResponse {
                        do {
                            let failResponse = try self.decoder.decode(SubmitPostError.self, from: data)
                            let resp = SubmitPostResponseContainer(success: SubmitPostReponse(result: "failure"), fail: SubmitPostError(error: true, code: failResponse.code, message: failResponse.message))
                            didProcessResponse = true
                            handler(.success(resp))
                        } catch {
                            // ChattyService submitPost - failResponse fail
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    public func getRaters(postId: Int, handler: @escaping (Result<RatersResponse, Error>) -> Void) {
        guard
            var urlComponents = URLComponents(string: "https://www.shacknews.com/api2/api-index.php")
            else { preconditionFailure("Can't create url components...") }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "action2", value: "ext_get_all_raters"),
            URLQueryItem(name: "tag", value: "all"),
            URLQueryItem(name: "ids[]", value: (String(postId)))
        ]

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    var dataAsString = String(data: data, encoding: .utf8)
                    dataAsString = "{\"raters\": " + (dataAsString ?? "") + "}"
                    let articleData: Data? = dataAsString?.data(using: .utf8)
                    let response = try self?.decoder.decode(RatersWrapper.self, from: articleData ?? Data())
                    handler(.success(response?.raters ?? RatersResponse(status: "0", data: [Raters](), message: "error")))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func search(terms: String, author: String, parentAuthor: String, handler: @escaping (Result<[SearchChatPosts], Error>) -> Void) {
        guard
            var urlComponents = URLComponents(string: "https://winchatty.com/v2/search")
            else { preconditionFailure("Can't create url components...") }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "35"),
            URLQueryItem(name: "oldestFirst", value: "false")
        ]
        
        if terms != "" {
            urlComponents.queryItems?.append(URLQueryItem(name: "terms", value: terms))
        }
        if author != "" {
            urlComponents.queryItems?.append(URLQueryItem(name: "author", value: author))
        }
        if parentAuthor != "" {
            urlComponents.queryItems?.append(URLQueryItem(name: "parentAuthor", value: parentAuthor))
        }
        
        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    print("search success begin")
                    let data = data ?? Data()
                    let response = try self?.decoder.decode(SearchChat.self, from: data)
                    handler(.success(response?.posts ?? []))
                    print("search success end")
                } catch {
                    print("search fail")
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func getThreadByPost(postId: Int, handler: @escaping (Result<[ChatThread], Error>) -> Void) {
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/v2/getThread?id=\(postId)")
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
    
    @Published var activePostId: Int = 0
    
    @Published var didSubmitPost = false

    @Published var didTagPost = false
    @Published var showingTagNotice = false
    @Published var taggingNoticeText = "Tagged!"

    @Published var didGetChatStart = false
    @Published var didGetChatFinish = false
    @Published var didGetThreadStart = false
    @Published var didGetThreadFinish = false
    
    @Published var scrollTargetChat: Int?
    @Published var scrollTargetChatTop: Int?
    @Published var scrollTargetThread: Int?
    @Published var scrollTargetThreadTop: Int?

    // For pull to refresh
    @Published var gettingChat: Bool = false {
        didSet {
            if oldValue == false && gettingChat == true {
                #if os(iOS)
                // Delay long enough for the pull to refresh animation to complete...
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.getChat()
                }
                #endif
            }
        }
    }
    
    @Published var gettingThread: Bool = false {
        didSet {
            if oldValue == false && gettingThread == true {
                #if os(iOS)
                // Delay long enough for the pull to refresh animation to complete...
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.getThread()
                }
                #endif
            }
        }
    }

    func getChat() {
        self.didGetChatStart = true
        #if os(watchOS)
        self.threads = []
        self.gettingChat = true
        #endif
        #if os(OSX)
        self.threads = []
        self.gettingChat = true
        #endif
        service.getChat() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let threads):
                    self?.threads = threads
                case .failure:
                    self?.threads = []
                }
                DispatchQueue.main.async {
                    self?.didGetChatFinish = true
                    self?.gettingChat = false
                }
            }
        }
    }
    
    func getThread() {
        self.didGetThreadStart = true
        service.getThread(threadId: self.activeThreadId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let threads):
                    let threadId = self?.activeThreadId ?? 0
                    if let row = self?.threads.firstIndex(where: {$0.threadId == threadId}) {
                        if threads[0].posts.count > 0 {
                            self?.threads[row] = threads[0]
                        }
                    }
                case .failure:
                    print("failure to getThread")
                }
                DispatchQueue.main.async {
                    self?.didGetThreadFinish = true
                    self?.gettingThread = false
                }
            }
        }
    }
    
    // Tag post
    @Published private(set) var tagResponse: TagReponse = TagReponse(status: "0", data: nil, message: "")
    func tag(postId: Int, tag: String, untag: String) {
        service.tag(postId: postId, tag: tag, untag: untag) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.tagResponse = response
                case .failure:
                    self?.tagResponse = TagReponse(status: "0", data: nil, message: "")
                }
            }
        }
    }
    
    // Submit post
    @Published var submitPostSuccessMessage: String = ""
    @Published var submitPostErrorMessage: String = ""
    @Published private(set) var submitPostResponse: SubmitPostResponseContainer = SubmitPostResponseContainer(success: SubmitPostReponse(result: ""), fail: SubmitPostError(error: false, code: "ERR_NONE", message: "No error."))
    func submitPost(postBody: String, postId: Int) {
        self.didSubmitPost = true
        service.submitPost(postBody: postBody, postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                self?.submitPostSuccessMessage = ""
                self?.submitPostErrorMessage = ""

                switch result {
                case .success(let response):
                    self?.submitPostResponse = response
                    if response.success.result == "success" {
                        self?.submitPostSuccessMessage = "Post submitted successfully."
                        self?.submitPostErrorMessage = ""
                    } else {
                        self?.submitPostSuccessMessage = ""
                        self?.submitPostErrorMessage = response.fail.message
                    }
                case .failure:
                    self?.submitPostResponse = SubmitPostResponseContainer(success: SubmitPostReponse(result: "failure"), fail: SubmitPostError(error: true, code: "ERR_SERVER", message: "Error posting."))
                    self?.submitPostSuccessMessage = ""
                    self?.submitPostErrorMessage = "Error posting.  Please try again."
                }
            }
        }
    }
    
    // Taggers / Lolers
    @Published private(set) var raters: [Raters] = []
    func getRaters(postId: Int, completionSuccess: @escaping ()->(), completionFail: @escaping ()->()) {
        service.getRaters(postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ratersResponse):
                    self?.raters = ratersResponse.data
                    completionSuccess()
                case .failure:
                    self?.raters = []
                    completionFail()
                }
            }
        }
    }
    
    // Search
    @Published private(set) var searchResults: [SearchChatPosts] = []
    func search(terms: String, author: String, parentAuthor: String, completion: @escaping ()->()) {
        service.search(terms: terms, author: author, parentAuthor: parentAuthor) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let foundPosts):
                    print("search results: \(foundPosts.count)")
                    self?.searchResults = foundPosts
                    completion()
                case .failure:
                    print("search failure")
                    self?.searchResults = []
                }
            }
        }
    }

    // Load any thread
    @Published private(set) var searchedThreads: [ChatThread] = []
    func getThreadByPost(postId: Int, completion: @escaping ()->()) {
        service.getThreadByPost(postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let foundThreads):
                    print("loadThreadByPost results: \(foundThreads.count)")
                    self?.searchedThreads = foundThreads
                    completion()
                case .failure:
                    print("loadThreadByPost failure")
                    self?.searchedThreads = []
                }
            }
        }
    }
    
}
