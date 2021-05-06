//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    var lols: [String: Int] = [String: Int]()
    var chatlols: [ChatLols] = [ChatLols]()
    var expanded: Bool = false
    
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
            if chatlols.count > 0 {
                if self.expanded {
                    ForEach(self.chatlols.sorted(by: <), id: \.self) { lol in
                        if lol.count > 0 {
                            Text(lol.tag)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(PostTagColor[lol.tag])
                            +
                            Text(" \(lol.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(PostTagColor[lol.tag])
                        }
                    }
                } else {
                    ForEach(self.chatlols.sorted(by: <), id: \.self) { lol in
                                            if lol.count > 0 {
                            Text("A") // 'A' is a tag
                                .lineLimit(1)
                                .fixedSize()
                                .font(.custom("tags", size: 8, relativeTo: .caption))
                                .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                                .foregroundColor(PostTagColor[lol.tag])
                        }
                    }
                }
            } else {
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
            }
        #endif
        #if os(watchOS)
            HStack {
                ForEach(self.lols.sorted(by: <), id: \.key) { key, value in
                    if value > 0 {
                        Text("A") // 'A' is a tag
                            .lineLimit(1)
                            .fixedSize()
                            .font(.custom("tags", size: 8, relativeTo: .caption))
                            .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                            .foregroundColor(PostTagColor[key])
                    }
                }
            }
        #endif
    }
}

struct LolView_Previews: PreviewProvider {
    static var previews: some View {
        LolView(lols: ["lol": 5, "inf": 2, "unf": 6, "tag": 1])
    }
}
