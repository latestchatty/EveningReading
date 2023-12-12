//
//  PushNotificationService.swift
//  EveningReading Extension
//
//  Created by Chris Hodge on 5/14/21.
//

import Foundation
import SwiftUI

class PushNotificationsService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationsService()
    
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

extension PushNotificationsService {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificationData = response
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            PushNotificationsService.shared.notificationLink = aps.description
        }
        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)
    {
        // ...
    }
}
