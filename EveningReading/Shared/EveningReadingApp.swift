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
    @Environment(\.scenePhase) var phase
    
    @StateObject var appSessionStore = AppSessionStore(service: .init())
    @StateObject var chatStore = ChatStore(service: .init())
    @StateObject var articleStore = ArticleStore(service: .init())
    @StateObject var messageStore = MessageStore(service: .init())
    @StateObject var viewedPostsService = ViewedPostsStore()
    
    #if os(iOS)
    @StateObject var notifications = Notifications.shared //Notifications()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var shackTags = ShackTags.shared
    #endif
    
    #if os(iOS)
    var body: some Scene {
        WindowGroup {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
                    .environmentObject(messageStore)
                    .environmentObject(notifications)
                    .environmentObject(shackTags)
                    .environmentObject(viewedPostsService)
                    .preferredColorScheme(appSessionStore.isDarkMode ? .dark : .light)
                
            } else {
                iPhoneContentView()
                    .environmentObject(appSessionStore)
                    .environmentObject(chatStore)
                    .environmentObject(articleStore)
                    .environmentObject(messageStore)
                    .environmentObject(notifications)
                    .environmentObject(shackTags)
                    .environmentObject(viewedPostsService)
                    .preferredColorScheme(appSessionStore.isDarkMode ? .dark : .light)
            }
        }
        /*
         .onChange(of: phase) { newPhase in
         if newPhase == .active {
         #if os(iOS)
         UIApplication.shared.applicationIconBadgeNumber = 0
         #endif
         }
         }
         */
        /*
         .onChange(of: phase) { newPhase in
         switch newPhase {
         case .active:
         // App became active
         case .inactive:
         // App became inactive
         case .background:
         // App is running in the background
         @unknown default:
         // Fallback for future cases
         }
         }
         */
    }
    #elseif os(macOS)
    var body: some Scene {
        WindowGroup {
            macOSContentView()
                .environmentObject(appSessionStore)
                .environmentObject(chatStore)
                .environmentObject(articleStore)
                .environmentObject(messageStore)
                .environmentObject(viewedPostsService)
                .lineSpacing(4 + (FontSettings.instance.fontOffset * 0.25))
                .preferredColorScheme(.dark)
        }
        .commands {
            CommandGroup(after: CommandGroupPlacement.toolbar) {
                Button("Increase font size") {
                    FontSettings.instance.fontOffset = FontSettings.instance.fontOffset + 1
                }
                .keyboardShortcut("+", modifiers: [.command])
                
                Button("Decrease font size") {
                    FontSettings.instance.fontOffset = FontSettings.instance.fontOffset - 1
                }
                .keyboardShortcut("-", modifiers: [.command])
                
                Button("Reset font size") {
                    FontSettings.instance.fontOffset = 0
                }
                .keyboardShortcut("0", modifiers: [.command])
            }
        }
    }
    #endif
}


// Push notifications
#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        return true
    }
    
    // No callback in simulator, must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token Raw: \(deviceToken)")
        print("Device Token: \(token)")
        
        let deviceUUID = UUID().uuidString
        let deviceTokenClean = token.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        var deviceName = UIDevice.current.name
        let deviceModel = UIDevice.current.model
        let deviceVersion = UIDevice.current.systemVersion
        
        let alphabetOnly = "[^A-Za-z0-9]+"
        deviceName = deviceName.replacingOccurrences(of: alphabetOnly, with: "", options: [.regularExpression])
        
        let defaults = UserDefaults.standard
        defaults.set(deviceUUID, forKey: "PushNotificationUUID")
        defaults.set(deviceTokenClean, forKey: "PushNotificationToken")
        defaults.set(deviceName, forKey: "PushNotificationName")
        defaults.set(deviceModel, forKey: "PushNotificationModel")
        defaults.set(deviceVersion, forKey: "PushNotificationVersion")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            //print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
#endif
