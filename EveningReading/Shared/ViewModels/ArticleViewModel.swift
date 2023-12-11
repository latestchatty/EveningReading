//
//  ArticleViewModel.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/8/23.
//

import Foundation

class ArticleViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    
    public func getArticles() {
        getArticlesFromAPI() { [weak self] result in
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
    
    private func getArticlesFromAPI(handler: @escaping (Result<[Article], Error>) -> Void) {
        let session: URLSession = .shared
        let decoder: JSONDecoder = .init()
        
        guard
            let urlComponents = URLComponents(string: "https://winchatty.com/chatty/stories.json")
            else { preconditionFailure("Can't create url components...") }

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }

        session.dataTask(with: url) { data, _, error in
            if let error = error {
                handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    var dataAsString = String(data: data, encoding: .utf8)
                    dataAsString = "{\"articles\": " + (dataAsString ?? "") + "}"
                    let articleData: Data? = dataAsString?.data(using: .utf8)
                    let response = try decoder.decode(ArticleWrapper.self, from: articleData ?? Data())
                    handler(.success(response.articles))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}
