//
//  SyncWatchView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 4/8/23.
//

import SwiftUI

struct SyncWatchView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var watchServiceStatus = "Open Evening Reading on your Watch..."
    let sendUsernameTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text(watchServiceStatus)
            if !watchServiceStatus.starts(with: "Successfully") {
                ProgressView()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color.primary)
            } else {
                EmptyView()
                    .frame(width: 120, height: 120)
            }
        }
        .navigationBarTitle("Sync With Watch", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16))
        .onReceive(sendUsernameTimer) { _ in
            watchServiceStatus = WatchService.shared.sendUsername()
        }
    }
}
