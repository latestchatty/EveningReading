//
//  RedactedContentLoader.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 12/8/23.
//

import Foundation

class RedactedContentLoader {
    static func getArticles() -> [Article] {
        return loadRedactedData("Articles.json")
    }
    
    static func getMessages() -> MessageResponse {
        return loadRedactedData("Messages.json")
    }
    
    static func getChat() -> Chat {
        return loadRedactedData("Chat.json")
    }
    
    static func getSearchData() -> SearchChat {
        return loadRedactedData("SearchResults.json")
    }
    
    static func loadRedactedData<T: Decodable>(_ filename: String) -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
