//
//  RegisterPushService.swift
//  EveningReading
//
//  Created by Chris Hodge on 12/12/23.
//

import Foundation

class RegisterPushService: ObservableObject {
    @Published private(set) var registerPushResponse: RegisterPushResponse = RegisterPushResponse(status: 0, message: "")
        
    func register() {
       let username: String? = KeychainWrapper.standard.string(forKey: "Username")
       let defaults = UserDefaults.standard
       let deviceTokenClean = defaults.object(forKey: "PushNotificationToken") as? String ?? ""
       let deviceName = defaults.object(forKey: "PushNotificationName") as? String ?? ""

       if username != nil && username != "" && deviceTokenClean != "" {
           let alphaNumericOnly = "[^A-Za-z0-9]+"
           if let cleanUsername = username?.replacingOccurrences(of: alphaNumericOnly, with: "", options: [.regularExpression]) {
               registerWithAPI(username: cleanUsername, deviceName: deviceName, deviceToken: deviceTokenClean) { [weak self] result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let response):
                           self?.registerPushResponse = response
                       case .failure:
                           self?.registerPushResponse = RegisterPushResponse(status: 0, message: "fail")
                       }
                   }
               }
           }
       }
    }
    
    private func registerWithAPI(username: String, deviceName: String, deviceToken: String, handler: @escaping (Result<RegisterPushResponse, Error>) -> Void) {
        if let apnsKey = Bundle.main.infoDictionary?["APNS_KEY"] as? String {
            let session: URLSession = .shared
            let decoder: JSONDecoder = .init()
            guard
                var urlComponents = URLComponents(string: "https://www.erapns.com/APNS/adduser.php")
                else { preconditionFailure("Can't create url components...") }

            urlComponents.queryItems = [
             URLQueryItem(name: "key", value: apnsKey),
             URLQueryItem(name: "username", value: username),
             URLQueryItem(name: "device", value: deviceName),
             URLQueryItem(name: "token", value: deviceToken)
            ]
            
            guard
                let url = urlComponents.url
                else { preconditionFailure("Can't create url from url components...") }
            
            let urlSession: URLSession = .shared
            
            urlSession.dataTask(with: url) { data, _, error in
                if let error = error {
                    handler(.failure(error))
                } else {
                    let data = data ?? Data()
                    print("push register user success")
                    print("\(data)")
                    handler(.success(RegisterPushResponse(status: 1, message: "success")))
                }
            }.resume()
        } else {
            handler(.failure(NSError(domain:"", code: 500, userInfo:nil)))
        }
    }
    
    func registernew() {
       let username: String = KeychainWrapper.standard.string(forKey: "Username") ?? ""
       let defaults = UserDefaults.standard
       let deviceTokenClean = defaults.object(forKey: "PushNotificationToken") as? String ?? ""
       let deviceName = defaults.object(forKey: "PushNotificationName") as? String ?? ""

       if username != "" && deviceTokenClean != "" {
           registerNewWithAPI(username: username, deviceName: deviceName, deviceToken: deviceTokenClean) { [weak self] result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let response):
                       self?.registerPushResponse = response
                   case .failure:
                       self?.registerPushResponse = RegisterPushResponse(status: 0, message: "fail")
                   }
               }
           }
       }
    }
    
    private func registerNewWithAPI(username: String, deviceName: String, deviceToken: String, handler: @escaping (Result<RegisterPushResponse, Error>) -> Void) {
        if let apnsKey = Bundle.main.infoDictionary?["APNS_KEY"] as? String {
            guard
                var urlComponents = URLComponents(string: "https://www.erapns.com/APNS/addusernew.php")
                else { preconditionFailure("Can't create url components...") }

            urlComponents.queryItems = [
             URLQueryItem(name: "key", value: apnsKey),
             URLQueryItem(name: "username", value: username),
             URLQueryItem(name: "device", value: deviceName),
             URLQueryItem(name: "token", value: deviceToken)
            ]
            
            guard
                let url = urlComponents.url
                else { preconditionFailure("Can't create url from url components...") }
            
            let urlSession: URLSession = .shared
            
            urlSession.dataTask(with: url) { data, _, error in
                if let error = error {
                    handler(.failure(error))
                } else {
                    let data = data ?? Data()
                    print("push register user success")
                    print("\(data)")
                    handler(.success(RegisterPushResponse(status: 1, message: "success")))
                }
            }.resume()
        } else {
            handler(.failure(NSError(domain:"", code: 500, userInfo:nil)))
        }
    }
}
