//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    @EnvironmentObject var chatStore: ChatStore
    
    #if os(OSX)
    @State var showTagUsers: Bool = false
    #endif
    
    var lols: [ChatLols] = [ChatLols]()
    var expanded: Bool = false
    var capsule: Bool = false
    var postId: Int = 0
    
    #if os(iOS)
    func truncateTag(tagType: String) -> Bool {
        var tagCounts = [String: Int]()
        var tagTypeCount = 0
        for tag in PostTag.allCases {
            tagCounts[tag.rawValue] = 0
        }
        for lol in self.lols {
            tagCounts[String("\(lol.tag)")] = lol.count
            if lol.count > 0 {
                tagTypeCount += 1
            }
        }
        
        // if there are more than 3 types of tags as this tag has
        // fewer than 2 then do not show this tag
        if let count = tagCounts[tagType] {
            if tagTypeCount > 4 && count < 2 {
                return true
            }
        }
        
        // show the tag
        return false
    }
    #endif
    
    var body: some View {
        // Lols
        #if os(iOS)
            if self.expanded {
                // Display as label with count
                HStack (alignment: .center) {
                    Text(" ")
                        .font(.caption2)
                        .fontWeight(.bold)
                    ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                        if lol.count > 0 && !truncateTag(tagType: lol.tag) {
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
            } else {
                // Display as tag icon
                ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                    Text("A")
                        .lineLimit(1)
                        .fixedSize()
                        .font(.custom("tags", size: 8, relativeTo: .caption))
                        .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
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
                            self.showTagUsers = true
                        }) {
                            Text("Who's Tagging?")
                            Image(systemName: "tag.circle")
                        }
                    }
                }
            } else if self.lols.count > 0 {
                if self.expanded {
                    // Display as label with count
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
                        macOSWhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
                            .frame(width: 5, height: 0)
                    }
                    .contextMenu {
                        if self.lols.count > 0 {
                            Button(action: {
                                // show who's tagging
                                self.showTagUsers = true
                            }) {
                                Text("Who's Tagging?")
                                Image(systemName: "tag.circle")
                            }
                        }
                    }
                } else {
                    // Display as tag icon
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
                        macOSWhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
                            .frame(width: 5, height: 0)
                    }
                    .contextMenu {
                        if self.lols.count > 0 {
                            Button(action: {
                                // show who's tagging
                                self.showTagUsers = true
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
            .environmentObject(ChatStore(service: ChatService()))
    }
}
