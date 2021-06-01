//
//  MessageService.swift
//  iOS
//
//  Created by Chris Hodge on 8/11/20.
//

import Foundation
import SwiftUI

struct MessageWrapper: Hashable, Codable {
    var messages: MessageResponse
}

struct MessageResponse: Hashable, Codable {
    var page: Int
    var totalPages: Int
    var totalMessages: Int
    var messages: [Message]
}

struct Message: Hashable, Codable {
    var id: Int
    var from: String
    var to: String
    var subject: String
    var date: String
    var body: String
    var unread: Bool
}

struct MessageCount: Hashable, Codable {
    var total: Int
    var unread: Int
}

struct SubmitMessageResponseContainer: Hashable, Codable {
    var success: SubmitMessageResponse
    var fail: SubmitMessageError
}

struct SubmitMessageResponse: Hashable, Codable {
    var result: String
}

struct SubmitMessageError: Hashable, Codable {
    var error: Bool
    var code: String
    var message : String
}

struct MarkMessageContainer: Hashable, Codable {
    var success: MarkMessageResponse
    var fail: MarkMessageError
}

struct MarkMessageResponse: Hashable, Codable {
    var result: String
}

struct MarkMessageError: Hashable, Codable {
    var type: String
    var title: String
    var status: Int
    var traceId: String
    var errors: MarkMessageErrors
}

struct MarkMessageErrors: Hashable, Codable {
    var MessageId: [String]
}

class MessageService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func getMessages(page: String, handler: @escaping (Result<MessageResponse, Error>) -> Void) {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")
        
        let msgsUrl = URL(string: "https://winchatty.com/v2/getMessages")!
        var components = URLComponents(url: msgsUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "folder", value: "inbox"),
            URLQueryItem(name: "page", value: page)
        ]
        
        guard
            let query = components.url!.query
            else { preconditionFailure("Can't create url components...") }
        
        var request = URLRequest(url: msgsUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)

        session.dataTask(with: request as URLRequest) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    var dataAsString = String(data: data, encoding: .utf8)
                    dataAsString = "{\"messages\": " + (dataAsString ?? "") + "}"
                    let msgData: Data? = dataAsString?.data(using: .utf8)
                    let response = try self?.decoder.decode(MessageWrapper.self, from: msgData ?? Data())
                    handler(.success(response?.messages ?? MessageResponse(page: 0, totalPages: 0, totalMessages: 0, messages: [Message]())))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func getCount(handler: @escaping (Result<MessageCount, Error>) -> Void) {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")
        
        let msgCountUrl = URL(string: "https://winchatty.com/v2/getMessageCount")!
        var components = URLComponents(url: msgCountUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        
        guard
            let query = components.url!.query
            else { preconditionFailure("Can't create url components...") }
        
        var request = URLRequest(url: msgCountUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)

        session.dataTask(with: request as URLRequest) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let dataAsString = String(data: data, encoding: .utf8)
                    let msgData: Data? = dataAsString?.data(using: .utf8)
                    let response = try self?.decoder.decode(MessageCount.self, from: msgData ?? Data())
                    handler(.success(response ?? MessageCount(total: 0, unread: 0)))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func submitMessage(username: String, password: String, recipient: String, subject: String, body: String, handler: @escaping (Result<SubmitMessageResponseContainer, Error>) -> Void) {
        
        let newPostUrl = URL(string: "https://winchatty.com/v2/sendMessage")!
        var components = URLComponents(url: newPostUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "to", value: recipient),
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
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
                        let successResponse = try self.decoder.decode(SubmitMessageResponse.self, from: data)
                        // MessageService submitMessage - successResponse success
                        print("successResponse result \(successResponse.result)")
                        let resp = SubmitMessageResponseContainer(success: SubmitMessageResponse(result: "success"), fail: SubmitMessageError(error: false, code: "ERR_NONE", message: "No error."))
                        didProcessResponse = true
                        handler(.success(resp))
                    } catch {
                        // MessageService submitMessage - successResponse fail
                    }

                    if !didProcessResponse {
                        do {
                            let failResponse = try self.decoder.decode(SubmitMessageError.self, from: data)
                            // MessageService submitMessage - failResponse success
                            // print("failResponse message \(failResponse.message)")
                            let resp = SubmitMessageResponseContainer(success: SubmitMessageResponse(result: "failure"), fail: SubmitMessageError(error: true, code: failResponse.code, message: failResponse.message))
                            didProcessResponse = true
                            handler(.success(resp))
                        } catch {
                            // MessageService submitMessage - failResponse fail
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    public func markMessage(messageid: Int, handler: @escaping (Result<MarkMessageContainer, Error>) -> Void) {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")
        
        let newPostUrl = URL(string: "https://winchatty.com/v2/markMessageRead")!
        var components = URLComponents(url: newPostUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "messageId", value: String(messageid))
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
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    var didProcessResponse = false

                    do {
                        let successResponse = try self.decoder.decode(MarkMessageResponse.self, from: data)
                        let resp = MarkMessageContainer(success: MarkMessageResponse(result: "success"), fail: MarkMessageError(type: "error", title: "error", status: 0, traceId: "error", errors: MarkMessageErrors(MessageId: ["0"])))
                        didProcessResponse = true
                        handler(.success(resp))
                    } catch {
                        // MessageService markMessage - successResponse fail
                    }

                    if !didProcessResponse {
                        do {
                            let failResponse = try self.decoder.decode(MarkMessageError.self, from: data)
                            let resp = MarkMessageContainer(success: MarkMessageResponse(result: "failure"), fail: MarkMessageError(type: "error", title: "error", status: 400, traceId: "error", errors: MarkMessageErrors(MessageId: ["0"])))
                            didProcessResponse = true
                            handler(.success(resp))
                        } catch {
                            // MessageService markMessage - failResponse fail
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var scrollTarget: Int?
    @Published var scrollTargetTop: Int?
    @Published var messageCount: MessageCount = MessageCount(total: 0, unread: 0)
    @Published var fetchComplete: Bool = false
    @Published var markedMessages: [Int] = [0]
    
    #if os(iOS)
    @Published var messageTemplateBegin = ""
    @Published var messageTemplateEnd = ""
    private var messageCountTimer: Timer? = nil
    #endif
    
    @Published private(set) var submitMessageResponse: SubmitMessageResponseContainer = SubmitMessageResponseContainer(success: SubmitMessageResponse(result: ""), fail: SubmitMessageError(error: false, code: "ERR_NONE", message: "No error."))
    
    @Published private(set) var markMessageResponse: MarkMessageContainer = MarkMessageContainer(success: MarkMessageResponse(result: "success"), fail: MarkMessageError(type: "error", title: "error", status: 0, traceId: "error", errors: MarkMessageErrors(MessageId: ["0"])))
    
    //private var timer : Timer? = nil
    
    private var mailUsername: String = ""
    private var mailPassword: String = ""
    
    @Published var gettingMessages: Bool = false {
        didSet {
            if oldValue == false && gettingMessages == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.getMessages(page: "1", append: false, delay: 0)
                }
            }
        }
    }
    
    private let service: MessageService
    init(service: MessageService) {
        self.service = service
        #if os(iOS)
        messageCountTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            self.getCount()
        }
        loadPostTemplate()
        #endif
    }
    
    func getMessages(page: String, append: Bool, delay: Int) {
        service.getMessages(page: page) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                switch result {
                case .success(let msgReponse):
                    if !append {
                        self?.messages = msgReponse.messages
                        self?.fetchComplete = true
                        self?.gettingMessages = false
                        
                        if msgReponse.totalPages > 1 {
                            for pageNum in 2...msgReponse.totalPages {
                                if self != nil {
                                    self!.getMessages(page: String(pageNum), append: true, delay: pageNum-1)
                                }
                            }
                        }
                    } else {
                        self?.messages.append(contentsOf: msgReponse.messages)
                    }
                    
                case .failure:
                    self?.messages = []
                    self?.fetchComplete = true
                    self?.gettingMessages = false
                }
            }
        }
    }
    
    func getCount() {
        service.getCount() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let msgCount):
                    self?.messageCount = msgCount
                    #if os(iOS)
                    UIApplication.shared.applicationIconBadgeNumber = msgCount.unread
                    #endif
                case .failure:
                    self?.messageCount = MessageCount(total: 0, unread: 0)
                }
            }
        }
    }
    
    func submitMessage(recipient: String, subject: String, body: String) {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let password: String? = KeychainWrapper.standard.string(forKey: "Password")

        service.submitMessage(username: username ?? "", password: password ?? "", recipient: recipient, subject: subject, body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.submitMessageResponse = response
                    if response.success.result == "success" {
                        // MessageService submitMessage message sent
                    } else {
                        // MessageService submitMessage message not sent
                    }
                case .failure:
                    // MessageService submitMessage failure
                    self?.submitMessageResponse = SubmitMessageResponseContainer(success: SubmitMessageResponse(result: "failure"), fail: SubmitMessageError(error: true, code: "ERR_SERVER", message: "Error posting."))
                }
            }
        }
    }
    
    func getComplaintText(author: String, postId: Int) -> String {
        return String("I would like to report user '\(author)', author of post http://www.shacknews.com/chatty?id=\(postId)#item_\(postId) for not adhering to the Shacknews guidelines.")
    }
    
    func submitComplaint(author: String, postId: Int) {
        if let shackERUser = Bundle.main.infoDictionary?["SHACK_ERUSER"] as? String {
            if let shackERPass = Bundle.main.infoDictionary?["SHACK_ERPASS"] as? String {
                service.submitMessage(username: shackERUser, password: shackERPass, recipient: "Duke Nuked", subject: "Reporting Author of Post", body: getComplaintText(author: author, postId: postId)) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            self?.submitMessageResponse = response
                            if response.success.result == "success" {
                                // MessageService submitComplaint message sent
                            } else {
                                // MessageService submitComplaint message not sent
                            }
                        case .failure:
                            // MessageService submitComplaint failure
                            self?.submitMessageResponse = SubmitMessageResponseContainer(success: SubmitMessageResponse(result: "failure"), fail: SubmitMessageError(error: true, code: "ERR_SERVER", message: "Error posting."))
                        }
                    }
                }
            }
        }
    }
    
    func markMessage(messageid: Int) {
        markedMessages.append(messageid)        
        service.markMessage(messageid: messageid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.markMessageResponse = response
                    if response.success.result == "success" {
                        // MessageService markMessage message marked
                    } else {
                        // MessageService markMessage message not marked
                    }
                case .failure:
                    // MessageService markMessage failure
                    self?.markMessageResponse = MarkMessageContainer(success: MarkMessageResponse(result: "error"), fail: MarkMessageError(type: "error", title: "error", status: 0, traceId: "error", errors: MarkMessageErrors(MessageId: ["0"])))
                }
            }
        }
    }
    
    func clearMessages() {
        self.messages.removeAll()
        self.messageCount = MessageCount(total: 0, unread: 0)
        self.mailUsername = ""
        self.mailPassword = ""
        self.fetchComplete = false
    }
    
    #if os(iOS)
    func loadPostTemplate() {
        // Preload message template HTML/CSS
        messageTemplateBegin = "<html><head><meta content='text/html; charset=utf-8' http-equiv='content-type'><meta content='initial-scale=1.0; maximum-scale=1.0; user-scalable=0;' name='viewport'><style>"
        let messageTemplateBegin2 = "</style></head><body>"
        messageTemplateEnd = "</body></html>"
        if let filepath = Bundle.main.path(forResource: "Stylesheet", ofType: "css") {
            do {
                let postTemplate = try String(contentsOfFile: filepath)
                let postTemplateStyled = postTemplate
                    .replacingOccurrences(of: "<%= linkColorLight %>", with: UIColor.black.toHexString())
                    .replacingOccurrences(of: "<%= linkColorDark %>", with: UIColor.systemTeal.toHexString())
                    .replacingOccurrences(of: "<%= jtSpoilerDark %>", with: "#21252b")
                    .replacingOccurrences(of: "<%= jtSpoilerLight %>", with: "#8e8e93")
                    .replacingOccurrences(of: "<%= jtOliveDark %>", with: UIColor(Color("OliveText")).toHexString())
                    .replacingOccurrences(of: "<%= jtOliveLight %>", with: "#808000")
                    .replacingOccurrences(of: "<%= jtLimeLight %>", with: "#A2D900")
                    .replacingOccurrences(of: "<%= jtLimeDark %>", with: "#BFFF00")
                    .replacingOccurrences(of: "<%= jtPink %>", with: UIColor(Color("PinkText")).toHexString())
                self.messageTemplateBegin = self.messageTemplateBegin + postTemplateStyled
            } catch {
                // contents could not be loaded
            }
        } else {
            // Stylesheet.css not found!
        }
        messageTemplateBegin = messageTemplateBegin + messageTemplateBegin2
    }
    #endif
}
