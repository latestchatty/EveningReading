//
//  LoadingPushNotificationView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 6/1/21.
//

import SwiftUI

struct LoadingPushNotificationView: View {
    @EnvironmentObject var notifications: Notifications
    
    var body: some View {
        if notifications.notificationData != nil {
            ZStack {
                Color("PrimaryBackground").frame(width: 2600, height: 2600).offset(y: -80)
                LoadingView(show: .constant(true), title: .constant(""))
                    .padding(.bottom, 30)
            }
        } else {
            Color.clear.frame(width: 0, height: 0).offset(y: 0)
        }
    }
}

struct LoadingPushNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPushNotificationView()
            .environmentObject(Notifications())
    }
}
