//
//  AuthService.swift
//  iOS
//
//  Created by Chris Hodge on 8/14/20.
//

import Foundation

struct AuthResponse: Hashable, Codable {
    var isValid: Bool
    var isModerator: Bool
}

class AuthService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func auth(username: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
        let newPostUrl = URL(string: "https://winchatty.com/v2/verifyCredentials")!
        var components = URLComponents(url: newPostUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        let query = components.url!.query
        
        var request = URLRequest(url: newPostUrl)
        request.httpMethod = "POST"
        request.httpBody = Data(query!.utf8)

        session.dataTask(with: request as URLRequest) { [weak self] data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    let response = try self?.decoder.decode(AuthResponse.self, from: data)
                    handler(.success(response?.isValid ?? false))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}
