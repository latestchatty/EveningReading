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
    @Published var markedMessages: [Int] = [0]
    
    func getCount() {
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
    
    public func getCountFromAPI(handler: @escaping (Result<MessageCount, Error>) -> Void) {
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
    
    
}
