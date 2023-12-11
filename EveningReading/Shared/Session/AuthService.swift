//
//  AuthService.swift
//  iOS
//
//  Created by Chris Hodge on 8/14/20.
//

import Foundation

class AuthService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func auth(username: String, password: String, handler: @escaping (Result<Bool, Error>) -> Void) {
        let loginUrl = URL(string: "https://winchatty.com/v2/verifyCredentials")!
        var components = URLComponents(url: loginUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        let query = components.url!.query
                
        var request = URLRequest(url: loginUrl)
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
