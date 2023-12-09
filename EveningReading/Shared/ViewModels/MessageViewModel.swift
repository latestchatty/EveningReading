//
//  MessageViewModel.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/9/23.
//

import Foundation
import SwiftUI

class MessageViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var messageCount: MessageCount = MessageCount(total: 0, unread: 0)
    @Published var markedMessages: [Int] = []
    @Published var fetchComplete: Bool = false
    @Published var scrollTarget: Int?
    @Published var scrollTargetTop: Int?
    
    @Published var gettingMessages: Bool = false {
        didSet {
            if oldValue == false && gettingMessages == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.getMessages(page: 1, append: false, delay: 0)
                }
            }
        }
    }
    
    public func clearMessages() {
        self.messages.removeAll()
        self.messageCount = MessageCount(total: 0, unread: 0)
        self.fetchComplete = false
    }
    
    public func getCount() {
        getCountFromAPI() { [weak self] result in
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
    
    private func getCountFromAPI(handler: @escaping (Result<MessageCount, Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()
        
        let username = UserHelper.getUserName()
        let password = UserHelper.getUserPassword()
        
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
        
        session.dataTask(with: request as URLRequest) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let dataAsString = String(data: data, encoding: .utf8)
                    let msgData: Data? = dataAsString?.data(using: .utf8)
                    let response = try decoder.decode(MessageCount.self, from: msgData ?? Data())
                    handler(.success(response))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func getMessages(page: Int, append: Bool, delay: Int) {
        getMessagesFromAPI(page: page) { [weak self] result in
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
                                    self!.getMessages(page: pageNum, append: true, delay: pageNum - 1)
                                }
                            }
                        }
                    } else {
                        self?.messages.append(contentsOf: msgReponse.messages)
                    }
                    DispatchQueue.main.async {
                        self?.getCount()
                    }
                case .failure:
                    self?.messages = []
                    self?.fetchComplete = true
                    self?.gettingMessages = false
                }
            }
        }
    }
    
    private func getMessagesFromAPI(page: Int, handler: @escaping (Result<MessageResponse, Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()
        
        let username = UserHelper.getUserName()
        let password = UserHelper.getUserPassword()
        
        let msgsUrl = URL(string: "https://winchatty.com/v2/getMessages")!
        var components = URLComponents(url: msgsUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "folder", value: "inbox"),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard
            let query = components.url!.query
        else { preconditionFailure("Can't create url components...") }
        
        var request = URLRequest(url: msgsUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)
        
        session.dataTask(with: request as URLRequest) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    var dataAsString = String(data: data, encoding: .utf8)
                    dataAsString = "{\"messages\": " + (dataAsString ?? "") + "}"
                    let msgData: Data? = dataAsString?.data(using: .utf8)
                    let response = try decoder.decode(MessageWrapper.self, from: msgData ?? Data())
                    handler(.success(response.messages))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
    
    public func formatReply(recipient: String, body: String) -> String {
        var replySpacing = ""
        if recipient != "Duke Nuked" && body != " " {
            replySpacing = "\n\n--------------------\n\n\(recipient) Wrote:\n\n"
        }
        return replySpacing + body.newlineToBR
    }
    
    public func submitMessage(recipient: String, subject: String, body: String) {
        let username = UserHelper.getUserName()
        let password = UserHelper.getUserPassword()

        submitMessageToAPI(username: username, password: password, recipient: recipient, subject: subject, body: body) { result in
            DispatchQueue.main.async {
                // TODO: Show something in the UI if success vs fail?
                switch result {
                case .success(let response):
                    if response.result == "success" {
                        // Send message success
                        print("submitMessage message sent")
                    } else {
                        // Send message failure
                        print("submitMessage failure")
                    }
                case .failure:
                    // Send message failure
                    print("submitMessage failure")
                }
            }
        }
    }
    
    public func submitMessageToAPI(username: String, password: String, recipient: String, subject: String, body: String, handler: @escaping (Result<SubmitMessageResponse, Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()
        
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
                if try JSONSerialization.jsonObject(with: data, options: .mutableContainers) is [String: Any] {
                    var didProcessResponse = false
                    do {
                        let successResponse = try decoder.decode(SubmitMessageResponse.self, from: data)
                        didProcessResponse = true
                        handler(.success(successResponse))
                    } catch {
                        handler(.failure(error))
                    }
                    if !didProcessResponse {
                        handler(.failure(error!))
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    public func markMessage(messageid: Int) {
        markedMessages.append(messageid)
        markMessageViaAPI(messageid: messageid) { [weak self] result in
            DispatchQueue.main.async {
                // TODO: Show something in the UI if success vs fail?
                switch result {
                case .success(_):
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self?.getCount()
                    }
                case .failure:
                    print("markMessage failure")
                }
            }
        }
    }
    
    private func markMessageViaAPI(messageid: Int, handler: @escaping (Result<MarkMessageResponse, Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()

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
                if try JSONSerialization.jsonObject(with: data, options: .mutableContainers) is [String: Any] {
                    var didProcessResponse = false
                    do {
                        let successResponse = try decoder.decode(MarkMessageResponse.self, from: data)
                        didProcessResponse = true
                        handler(.success(successResponse))
                    } catch {
                        handler(.failure(error))
                    }
                    if !didProcessResponse {
                        handler(.failure(error!))
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    public func getComplaintText(author: String, postId: Int) -> String {
        return "I would like to report user '\(author)', author of post https://www.shacknews.com/chatty?id=" +  String(postId) + "#item_" + String(postId) + " for not adhering to the Shacknews guidelines."
    }
    
    public func submitComplaint(author: String, postId: Int) {
        if let shackERUser = Bundle.main.infoDictionary?["SHACK_ERUSER"] as? String {
            if let shackERPass = Bundle.main.infoDictionary?["SHACK_ERPASS"] as? String {
                submitMessageToAPI(username: shackERUser, password: shackERPass, recipient: "Duke Nuked", subject: "Reporting Author of Post", body: getComplaintText(author: author, postId: postId)) { [weak self] result in
                    DispatchQueue.main.async {
                        // TODO: Show some sort of indicator if success or fail?
                        switch result {
                        case .success:
                            print("submitComplaint success")
                        case .failure:
                            print("submitComplaint failed")
                        }
                    }
                }
            }
        }
    }
}
