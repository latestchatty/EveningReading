//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    var lols: [ChatLols] = [ChatLols]()
    var expanded: Bool = false
    var capsule: Bool = false
    
    var body: some View {
        // Lols
        #if os(iOS)
            if self.expanded {
                HStack {
                    Text(" ")
                        .font(.caption2)
                        .fontWeight(.bold)
                    ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                        if lol.count > 0 {
                            HStack {
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
                    }
                }
                .contextMenu {
                    if self.lols.count > 0 {
                        Button(action: {
                            // show who's tagging
                        }) {
                            Text("Who's Tagging?")
                            Image(systemName: "tag.circle")
                        }
                    }
                }
            } else {
                ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                    Text("A")
                        .lineLimit(1)
                        .fixedSize()
                        .font(.custom("tags", size: 8, relativeTo: .caption))
                        .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                        .foregroundColor(PostTagColor[lol.tag])
                }
            }
        #endif
        #if os(OSX)
            if self.capsule && lols.count > 0 {
                // Display as capsule with label and count
                HStack {
                    ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                        if lol.count > 0 {
                            HStack {
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
                            .padding(.init(top: 1, leading: 4, bottom: 1, trailing: 4))
                            .overlay(Capsule(style: .continuous)
                                        .stroke(PostTagColor[lol.tag]!))
                        }
                    }
                }
                .contextMenu {
                    if self.lols.count > 0 {
                        Button(action: {
                            // show who's tagging
                        }) {
                            Text("Who's Tagging?")
                            Image(systemName: "tag.circle")
                        }
                    }
                }
            } else if self.lols.count > 0 {
                // Display as label with count
                if self.expanded {
                    HStack {
                        ForEach(self.lols.sorted(by: <), id: \.self) { lol in
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
                    }
                    .contextMenu {
                        if self.lols.count > 0 {
                            Button(action: {
                                // show who's tagging
                            }) {
                                Text("Who's Tagging?")
                                Image(systemName: "tag.circle")
                            }
                        }
                    }
                // Display as tag icon
                } else {
                    HStack {
                        ForEach(self.lols.sorted(by: <), id: \.self) { lol in
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
                    .contextMenu {
                        if self.lols.count > 0 {
                            Button(action: {
                                // show who's tagging
                            }) {
                                Text("Who's Tagging?")
                                Image(systemName: "tag.circle")
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
        #endif
        #if os(watchOS)
            HStack {
                ForEach(self.lols.sorted(by: <), id: \.self) { lol in
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
        #endif
    }
}

struct LolView_Previews: PreviewProvider {
    static var previews: some View {
        LolView(lols: [ChatLols]())
    }
}
