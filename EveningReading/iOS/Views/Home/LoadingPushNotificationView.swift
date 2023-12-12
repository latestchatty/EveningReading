//
//  LoadingPushNotificationView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 6/1/21.
//

import SwiftUI

struct LoadingPushNotificationView: View {
    @EnvironmentObject var pushNotificationsService: PushNotificationsService
    
    var body: some View {
        if pushNotificationsService.notificationData != nil {
            ZStack {
                Color("PrimaryBackground").frame(width: BackgroundWidth, height: BackgroundHeight).offset(y: BackgroundOffset)
                LoadingView(show: .constant(true))
                    .padding(.bottom, 30)
            }
        } else {
            Color.clear.frame(width: 0, height: 0).offset(y: 0)
        }
    }
}
