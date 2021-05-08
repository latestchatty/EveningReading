//
//  ArticleService.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import Foundation

struct ArticleWrapper: Decodable {
    let articles: [Article]
}

struct Article: Hashable, Codable {
    var body: String
    var date: String
    var id: Int
    var name: String
    var preview: String
    var url: String
}

struct ArticleDetails: Hashable, Codable {
    var preview: String
    var name: String
    var body: Int
    var date: String
    var comment_count: Int
    var id: Int
    var thread_id: Int
}

class ArticleService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    public func getArticles(handler: @escaping (Result<[Article], Error>) -> Void) {
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/chatty/stories.json")
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
                    var dataAsString = String(data: data, encoding: .utf8)
                    dataAsString = "{\"articles\": " + (dataAsString ?? "") + "}" // hacky way to turn this into json JSONDecoder can handle... help?
                    let articleData: Data? = dataAsString?.data(using: .utf8)
                    let response = try self?.decoder.decode(ArticleWrapper.self, from: articleData ?? Data())
                    handler(.success(response?.articles ?? []))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}

class ArticleStore: ObservableObject {
    @Published private(set) var articles: [Article] = []

    private let service: ArticleService
    init(service: ArticleService) {
        self.service = service
    }
    
    func getArticles() {
        service.getArticles() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.articles = articles
                case .failure:
                    self?.articles = []
                }
            }
        }
    }
}
