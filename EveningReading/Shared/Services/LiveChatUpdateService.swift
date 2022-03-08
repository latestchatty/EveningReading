//
//  LiveChatUpdateService.swift
//  EveningReading
//
//  Created by Willie Zutz on 3/5/22.
//

import Foundation

enum ChatUpdateEventType: String, Codable {
    case newPost
    case categoryChange
    case lolCountsUpdate
    case readStatusUpdate
    case changePost
    case changeFreeze
    case unknown
}

struct NewPostUpdateEvent: ChatUpdateEvent, Codable {
    var eventId: Int
    var eventDate: String
    var eventType: ChatUpdateEventType
    var eventData: NewPostEventData?
}

struct NewPostEventData: Codable {
    var postId: Int
    var parentAuthor: String
}

struct UnknownUpdateEvent: ChatUpdateEvent, Codable {
    var eventId: Int
    var eventDate: String
    var eventType: ChatUpdateEventType
}

protocol ChatUpdateEvent: Codable {
    var eventId: Int { get set }
    var eventDate: String { get set }
    var eventType: ChatUpdateEventType { get set }
}

class LiveChatUpdateService {
    private struct WinchattyPollForEvent: Decodable {
        let lastEventId: Int
        let tooManyEvents: Bool
        var events: [ChatUpdateEvent] = [ChatUpdateEvent]()
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.lastEventId = try container.decode(Int.self, forKey: .lastEventId)
            self.tooManyEvents = try container.decode(Bool.self, forKey: .tooManyEvents)
            
            var eventArray = try container.nestedUnkeyedContainer(forKey: .events)
            
            while !eventArray.isAtEnd { do {
                if let event = try? eventArray.decode(NewPostUpdateEvent.self) {
                    events.append(event)
                } else if let event = try? eventArray.decode(UnknownUpdateEvent.self) {
                    events.append(event)
                }
            }}
        }
        
        enum CodingKeys: String, CodingKey {
            case lastEventId
            case events
            case tooManyEvents
            case eventType
        }
    }
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func getLatestEvents(lastEventId: Int, handler: @escaping (Result<[ChatUpdateEvent], Error>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
#if os(iOS)
        sessionConfig.waitsForConnectivity = false
        sessionConfig.timeoutIntervalForResource = 10.0
#endif
        let shortSession = URLSession(configuration: sessionConfig)
        
        guard
            var urlComponents = URLComponents(string: "https://winchatty.com/v2/pollForEvent")
        else { preconditionFailure("Can't create url components...") }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lastEventId", value: (String(lastEventId)))
        ]
        
        guard
            let url = urlComponents.url
        else { preconditionFailure("Can't create url from url components...") }
        
        shortSession.dataTask(with: url) { [weak self] data, _, err in
            if let e = err {
                handler(.failure(e))
            } else {
                do {
                    let data = data ?? Data()
                    let result = try self?.decoder.decode(WinchattyPollForEvent.self, from: data)
                    print("Latest Event Id: \(result!.lastEventId)")
                    handler(.success(result!.events))
                } catch {
                    print(error)
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func getNewestEventId(handler: @escaping (Result<Int, Error>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
#if os(iOS)
        sessionConfig.waitsForConnectivity = false
        sessionConfig.timeoutIntervalForResource = 10.0
#endif
        let shortSession = URLSession(configuration: sessionConfig)
        
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/v2/getNewestEventId")
        else { preconditionFailure("Can't create url components...") }
        
        guard
            let url = urlComponents.url
        else { preconditionFailure("Can't create url from url components...") }
        
        shortSession.dataTask(with: url) { [weak self] data, _, err in
            if let e = err {
                handler(.failure(e))
            } else {
                do {
                    let data = data ?? Data()
                    struct LatestEventId: Codable {
                        let eventId: Int
                    }
                    let result = try self?.decoder.decode(LatestEventId.self, from: data)
                    print("Latest Event Id: \(result!.eventId)")
                    handler(.success(result!.eventId))
                } catch {
                    print(error)
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}

class LiveChatStore: ObservableObject {
    
    private let service: LiveChatUpdateService
    private var timer: Timer?
    private var lastEventId: Int = 0
    
    init(service: LiveChatUpdateService) {
        self.service = service
    }
    
    @Published var newReplies: Int = 0
    @Published var newThreads: Int = 0
    @Published var newRepliesToLoggedInUser: Int = 0
    
    func start() {
        self.service.getNewestEventId() { eventIdResult in
            switch eventIdResult {
            case .success(let eventId):
                self.lastEventId = eventId
                DispatchQueue.main.async {
                    self.timer?.invalidate()
                    self.newReplies = 0
                    self.newThreads = 0
                    self.newRepliesToLoggedInUser = 0
                    self.timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { t in
                        self.service.getLatestEvents(lastEventId: self.lastEventId) { [weak self] result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let events):
                                    if events.count > 0 {
                                        self!.lastEventId = events.map({e in e.eventId}).max()!
                                        let newPostEvents = events.filter({ e in e.eventType == .newPost }) as! [NewPostUpdateEvent]
                                        self!.newReplies = newPostEvents.count + self!.newReplies
                                        self!.newRepliesToLoggedInUser = newPostEvents.filter({ e in e.eventData?.parentAuthor.lowercased() == UserUtils.getUserName().lowercased() }).count + self!.newRepliesToLoggedInUser
                                        self!.newThreads = newPostEvents.filter({ e in e.eventData?.parentAuthor == "" }).count + self!.newThreads
                                        
                                        print("Got \(events.count) events with a latest id of \(self!.lastEventId)\nNew Replies: \(self!.newReplies)\nNew Replies To User: \(self!.newRepliesToLoggedInUser)\nNew Threads: \(self!.newThreads)")
                                    } else {
                                        print("No new events since \(self!.lastEventId)")
                                    }
                                    
                                case .failure(let err):
                                    print("Failed to get latest events \(err)")
                                }
                            }
                        }
                    }
                }
            case .failure(let err):
                print("Failed to get latest eventId for refresh \(err)")
            }
        }
    }
    
    func stop () {
        timer?.invalidate()
    }
}
