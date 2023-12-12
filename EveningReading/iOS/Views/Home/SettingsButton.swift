//
//  SettingsButton.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var pushNotificationsService: PushNotificationsService
    var hide: Bool = false

    private func navigateTo(_ goToDestination: inout Bool) {
        appService.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        if pushNotificationsService.notificationData != nil {
            EmptyView()
        } else {
            HStack {
                Button(action: {
                    navigateTo(&appService.showingSettingsView)
                }) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .imageScale(.large)
                        .frame(width: 36)
                }
            }
        }
    }
}

