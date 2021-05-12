//
//  EveningReadingApp.swift
//  Shared
//
//  Created by Chris Hodge on 4/28/21.
//

import SwiftUI

@main
struct EveningReadingApp: App {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var appSessionStore = AppSessionStore(service: .init())
    @StateObject var chatStore = ChatStore(service: .init())
    @StateObject var articleStore = ArticleStore(service: .init())
    @StateObject var messageStore = MessageStore(service: .init())

    #if os(iOS)
    @StateObject var notifications = Notifications()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
                    .environmentObject(messageStore)
                    .environmentObject(notifications)
                    .preferredColorScheme(appSessionStore.isDarkMode ? .dark : .light)

            } else {
                iPhoneContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
                    .environmentObject(messageStore)
                    .environmentObject(notifications)
                    .preferredColorScheme(appSessionStore.isDarkMode ? .dark : .light)
            }
            #else
                macOSContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
            #endif
        }
    }
}

// Push notifications
#if os(iOS)
extension UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    //No callback in simulator -- must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}
class Notifications: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var notificationData: UNNotificationResponse?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}
extension Notifications {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificationData = response
        completionHandler()
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
class ERNotification: ObservableObject {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (allowed, error) in
            //This callback does not trigger on main loop be careful
            if allowed {
                print("PushNotification Allowed")
            } else {
                print("PushNotification Not allowed")
            }
        }
    }
    
    func setERNotification(title: String, subtitle: String, body: String, when: Double) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: when, repeats: false)
        let request = UNNotificationRequest.init(identifier: "ERNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}
#endif
