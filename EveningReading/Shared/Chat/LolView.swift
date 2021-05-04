//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    @Binding var lols: [String: Int]
    
    var body: some View {
        // Lols
        #if os(iOS)
        HStack {
            Text(" ")
                .font(.caption2)
                .fontWeight(.bold)
            ForEach(self.lols.sorted(by: <), id: \.key) { key, value in
                if value > 0 {
                    HStack {
                        Text(key)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(PostTagColor[key])
                        +
                        Text(" \(value)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(PostTagColor[key])
                    }
                }
            }
        }
        .contextMenu {
            //if self.hasLols {
                Button(action: {
                    // show who's tagging
                }) {
                    Text("Who's Tagging?")
                    Image(systemName: "tag.circle")
                }
            //}
        }
        #endif
        #if os(OSX)
        HStack {
            ForEach(self.lols.sorted(by: <), id: \.key) { key, value in
                if value > 0 {
                    HStack {
                        Text(key)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(PostTagColor[key])
                        +
                        Text(" \(value)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(PostTagColor[key])
                    }
                    .padding(.init(top: 1, leading: 4, bottom: 1, trailing: 4))
                    .overlay(Capsule(style: .continuous)
                                .stroke(PostTagColor[key]!))
                }
            }
        }
        #endif
    }
}

struct LolView_Previews: PreviewProvider {
    static var previews: some View {
        LolView(lols: .constant(["lol": 5, "inf": 2, "unf": 6, "tag": 1]))
    }
}
