//
//  macOSTagsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct macOSTagsView: View {
    @EnvironmentObject var appService: AppService
    
    @State private var webViewLoading: Bool = true
    @State private var webViewProgress: Double = 0.25
    @State private var goToPostId: Int = 0
    @State private var showingPost: Bool = false
    
    var body: some View {
        VStack {
            if self.webViewLoading {
                ProgressView(value: self.webViewProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(NSColor.systemBlue)))
                    .frame(maxWidth: .infinity)
            }
            macOSTagsWebView(webViewLoading: self.$webViewLoading, webViewProgress: self.$webViewProgress, goToPostId: self.$goToPostId, showingPost: self.$showingPost, username: .constant(appService.username), password: .constant(appService.password))
        }
        .navigationTitle("Tags")
    }
}
