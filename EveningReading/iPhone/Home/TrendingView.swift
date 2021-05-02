//
//  TrendingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct TrendingView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore

    func navigateTo(_ goToDestination: inout Bool) {
        appSessionStore.resetNavigation()
        goToDestination = true
    }
    
    private func filteredThreads() -> [ChatThread] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(chatData.threads.prefix(4))
        }
        return Array(chatData.threads.prefix(4))
    }
    
    var body: some View {
        VStack {
            // Heading
            VStack {
                HStack {
                    Text("Trending")
                        .font(.title2)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 35 : 20)
            }
            .padding(.top, 20)
            
            // Content
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 80) {
                        
                        ForEach(filteredThreads(), id: \.threadId) { thread in
                            GeometryReader { geometry in
                                TrendingCard(thread: .constant(thread))
                                .rotation3DEffect(Angle(degrees: Double((geometry.frame(in: .global).minX - 30) / -30)), axis: (x: 0, y: 10, z: 0))
                                .background(Color.clear)
                            }
                            .frame(width: 246, height: 360)
                        }
                        
                    }.padding(40)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 480)
                Spacer()
            }
            .padding(.top, -20)
        }
    }
}
struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingView()
    }
}
