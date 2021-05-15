//
//  NotificationService.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/14/21.
//

import Foundation
import SwiftUI

struct RegisterReponse {
    var status: Int
}

class NotificationService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    public func register(deviceUUID: String, deviceTokenClean: String, deviceName: String, deviceModel: String, deviceVersion: String, clientId: String, appName: String, appVersion: String, handler: @escaping (Result<RegisterReponse, Error>) -> Void) {
        let task = "register"

        guard
            var urlComponents = URLComponents(string: "https://www.woggle.net/lcappnotification/apns_new.php")
            else { preconditionFailure("Can't create url components...") }
                 
        urlComponents.queryItems = [
         URLQueryItem(name: "task", value: task),
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

        urlSession.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("push register error \(error)")
                //handler(.failure(error))
            } else {
                do {
                    let data = data ?? Data()
                    print("push register success")
                    print("\(data)")
                    handler(.success(RegisterReponse(status: 1)))
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
    
    @Published private(set) var registerResponse: RegisterReponse = RegisterReponse(status: 0)
        
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
                
                print("registering for push")
                service.register(deviceUUID: deviceUUID, deviceTokenClean: deviceTokenClean, deviceName: deviceName, deviceModel: deviceModel, deviceVersion: deviceVersion, clientId: clientIdClean, appName: appName, appVersion: appVersion) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            self?.registerResponse = response
                        case .failure:
                            self?.registerResponse = RegisterReponse(status: 0)
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
        notificationData = response
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            // Do what you want with the notification
            Notifications.shared.notificationLink = aps.description
        }
        completionHandler()
        print("got here 2")
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
#endif
