//
//  ViewedPostsService.swift
//  EveningReading (iOS)
//
//  Created by Willie Zutz on 8/26/21.
//

import Foundation
import Compression
import Gzip

class CloudSetting {
    private struct ClientData: Hashable, Codable {
        public var data: String
    }
    
    static func getCloudSetting<T>(settingName: String, defaultValue: T, handler: @escaping (Result<T, Error>) -> Void) {
        let urlSession = URLSession.shared
        
        #if os(iOS)
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        #elseif os(macOS)
        let defaults = UserDefaults.standard
        let username = defaults.object(forKey: "Username") as? String ?? ""
        #endif
        
        if username == "" { handler(.success(defaultValue)) }
        
        guard
            var urlComponents = URLComponents(string: "https://winchatty.com/v2/clientData/getClientData")
        else { preconditionFailure("Can't create url components...") }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "client", value: settingName)
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        urlSession.dataTask(with: request, completionHandler: {responseData, response, error in
            guard error == nil else {
                handler(.failure(error!))
                return
            }
            guard let responseData = responseData else {
                handler(.failure(error!))
                return
            }
            do {
                var decompressedData = Data()
                let jsonDecoder = JSONDecoder()
                let clientData = try jsonDecoder.decode(ClientData.self, from: responseData)
                
                if clientData.data != "" {
                    if let compressedData = Data(base64Encoded: clientData.data, options: [.ignoreUnknownCharacters]) {
//                        do {
//                            let outputFilter = try OutputFilter(.decompress, using: .zlib) {(d: Data?) -> Void in
//                                if let d = d {
//                                    decompressedData.append(d)
//                                }
//                            }
//
//                            try outputFilter.write(compressedData)
//                        } catch {
//                            fatalError("Error occurred during decoding: \(error.localizedDescription).")
//                        }
                        decompressedData = try compressedData.gunzipped()
                        
                        if let jObj = try JSONSerialization.jsonObject(with: decompressedData) as? T {
                            handler(.success(jObj))
                        }
                    }
                }
            }
            catch let err {
                handler(.failure(err))
            }
        })
        .resume()
    }
}

//class ViewedPostsService {
//
//
//}

class ViewedPostsStore: ObservableObject {
    //    private let service: ViewedPostsService
    //    init(service: ViewedPostsService) {
    //        self.service = service
    //    }
    
    @Published var viewedPosts: Set<Int> = []
    
    func getViewedPosts() {
        CloudSetting.getCloudSetting(settingName: "werdSeenPosts", defaultValue: [] as Set<Int>) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.viewedPosts = posts
                case .failure(_):
                    self?.viewedPosts = []
                }
            }
        }
    }
    
    public func syncMarkedPosts() {
        
    }
    
    public func markPostViewed(postId: Int) {
        self.viewedPosts.insert(postId)
    }
    
    public func isPostViewed(postId: Int) -> Bool {
        return self.viewedPosts.contains(postId)
    }
}
