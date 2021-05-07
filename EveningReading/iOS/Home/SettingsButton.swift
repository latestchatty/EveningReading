//
//  SettingsButton.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var appSessionStore: AppSessionStore

    private func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    var body: some View {
        HStack {
            Button(action: {
                navigateTo(&appSessionStore.showingSettingsView)
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

struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
