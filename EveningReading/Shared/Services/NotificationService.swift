//
//  NotificationService.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/14/21.
//

import Foundation
import SwiftUI

struct RegisterUserReponse {
    var status: Int
}

struct RegisterDeviceReponse {
    var status: Int
}

class NotificationService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    public func registerUser(clientId: String, handler: @escaping (Result<RegisterUserReponse, Error>) -> Void) {
        guard
            var urlComponents = URLComponents(string: "https://www.woggle.net/lcappnotification/change_new.php")
            else { preconditionFailure("Can't create url components...") }

        urlComponents.queryItems = [
         URLQueryItem(name: "action", value: "add"),
         URLQueryItem(name: "type", value: "user"),
         URLQueryItem(name: "getvanity", value: "1"),
         URLQueryItem(name: "getreplies", value: "1"),
         URLQueryItem(name: "user", value: clientId)
        ]
        
        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }
        
        let urlSession: URLSession = .shared
        
        urlSession.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("push register user error \(error)")
                //handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    print("push register user success")
                    print("\(data)")
                    handler(.success(RegisterUserReponse(status: 1)))
                } catch {
                    handler(.failure(error))
                    print("push register user error \(error)")
                }
            }
        }.resume()
    }
    
    public func registerDevice(deviceUUID: String, deviceTokenClean: String, deviceName: String, deviceModel: String, deviceVersion: String, clientId: String, appName: String, appVersion: String, handler: @escaping (Result<RegisterDeviceReponse, Error>) -> Void) {

        guard
            var urlComponents = URLComponents(string: "https://www.woggle.net/lcappnotification/apns_new.php")
            else { preconditionFailure("Can't create url components...") }
                 
        urlComponents.queryItems = [
         URLQueryItem(name: "task", value: "register"),
         URLQueryItem(name: "appname", value: appName),
         URLQueryItem(name: "appversion", value: appVersion),
         URLQueryItem(name: "deviceuid", value: deviceUUID),
         URLQueryItem(name: "devicetoken", value: deviceTokenClean),
         URLQueryItem(name: "devicename", value: deviceName),
         URLQueryItem(name: "devicemodel", value: deviceModel),
         URLQueryItem(name: "deviceversion", value: deviceVersion),
         URLQueryItem(name: "pushbadge", value: "enabled"),
         URLQueryItem(name: "pushalert", value: "enabled"),
         URLQueryItem(name: "pushsound", value: "enabled"),
         URLQueryItem(name: "clientid", value: clientId)
        ]

        guard
            let url = urlComponents.url
            else { preconditionFailure("Can't create url from url components...") }
             
        let urlSession: URLSession = .shared
        
        // print("\(url)")

        urlSession.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("push register error \(error)")
                //handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    print("push register success")
                    print("\(data)")
                    handler(.success(RegisterDeviceReponse(status: 1)))
                } catch {
                    handler(.failure(error))
                    print("push register error \(error)")
                }
            }
        }.resume()
    }
}

class NotificationStore: ObservableObject {
    
    private let service: NotificationService
    init(service: NotificationService) {
        self.service = service
    }
    
    @Published private(set) var registerUserResponse: RegisterUserReponse = RegisterUserReponse(status: 0)
    @Published private(set) var registerDeviceResponse: RegisterDeviceReponse = RegisterDeviceReponse(status: 0)
    
    func register() {
        let username: String? = KeychainWrapper.standard.string(forKey: "Username")
        let defaults = UserDefaults.standard
        let deviceUUID = defaults.object(forKey: "PushNotificationUUID") as? String ?? ""
        let deviceTokenClean = defaults.object(forKey: "PushNotificationToken") as? String ?? ""
        let deviceName = defaults.object(forKey: "PushNotificationName") as? String ?? ""
        let deviceModel = defaults.object(forKey: "PushNotificationModel") as? String ?? ""
        let deviceVersion = defaults.object(forKey: "PushNotificationVersion") as? String ?? ""
        
        if username != nil && username != "" && deviceTokenClean != "" {
            var appName = ""
            var appVersion = ""
            let clientId = username
            
            let alphabetOnly = "[^A-Za-z0-9]+"
            if let clientIdClean = clientId?.replacingOccurrences(of: alphabetOnly, with: "", options: [.regularExpression]) {
                
                let dict = Bundle.main.infoDictionary!
                if let name = dict["CFBundleName"] as? String {
                    appName = name
                }
                if let version = dict["CFBundleShortVersionString"] as? String {
                    appVersion = version
                }
                
                print("registering user for push")
                service.registerUser(clientId: clientIdClean) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            self?.registerUserResponse = response
                        case .failure:
                            self?.registerUserResponse = RegisterUserReponse(status: 0)
                        }
                    }
                }

                print("registering device for push")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    self.service.registerDevice(deviceUUID: deviceUUID, deviceTokenClean: deviceTokenClean, deviceName: deviceName, deviceModel: deviceModel, deviceVersion: deviceVersion, clientId: clientIdClean, appName: appName, appVersion: appVersion) { [weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                self?.registerDeviceResponse = response
                            case .failure:
                                self?.registerDeviceResponse = RegisterDeviceReponse(status: 0)
                            }
                        }
                    }
                }
            }
        }
    }
}

#if os(iOS)
class Notifications: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = Notifications()
    
    @Published var notificationData: UNNotificationResponse?
    @Published var notificationLink: String = ""
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func setNotificationLink(_ link: String) {
        self.notificationLink = link
    }
}

extension Notifications {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UNNotificationResponse received")
        notificationData = response
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            // Do what you want with the notification
            Notifications.shared.notificationLink = aps.description
        }
        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
#endif
