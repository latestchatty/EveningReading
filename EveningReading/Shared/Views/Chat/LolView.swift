//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    @EnvironmentObject var chatService: ChatService
    
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
        
        // If there are more than 3 types of tags and this tag has
        // fewer than 2 then do not show this tag to save space
        if let count = tagCounts[tagType] {
            if tagTypeCount > 4 && count < 2 {
                return true
            }
        }
        
        // show the tag
        return false
    }
    
    func getTagDelta(tagType: String) -> Int {
        let delta = (chatService.tagDelta[postId]?[tagType] ?? 0)
        return delta
    }
    
    func getRemovedTagDelta(tagType: String) -> Int {
        let addedDelta = (chatService.tagDelta[postId]?[tagType] ?? 0)
        //let removedDelta = (chatService.tagRemovedDelta[postId]?[tagType] ?? 0)
        //let total = lols.filter{$0.tag == tagType}.count
        if addedDelta > 0 {
            return 1
        } else {
            return 0
        }
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
                                Text(" \(lol.count + getTagDelta(tagType: lol.tag))")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(PostTagColor[lol.tag])
                            }
                        }
                    }
                    ForEach(PostTags.allCases, id: \.self) { tag in
                        if self.lols.filter({$0.tag == tag.rawValue}).count < 1 && getTagDelta(tagType: tag.rawValue) > 0 {
                            HStack {
                                Text(tag.rawValue + " 1")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(PostTagColor[tag.rawValue])
                            }
                        }
                    }
                }
            } else {
                // Display as tag icon
                ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                    if lol.count > 0 {
                        Text("A")
                            .lineLimit(1)
                            .fixedSize()
                            .font(.custom("tags", size: 8, relativeTo: .caption))
                            .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
                            .foregroundColor(PostTagColor[lol.tag])
                    }
                }
                ForEach(PostTags.allCases, id: \.self) { tag in
                    if self.lols.filter({$0.tag == tag.rawValue}).count < 1 && getTagDelta(tagType: tag.rawValue) > 0 {
                        Text("A")
                            .lineLimit(1)
                            .fixedSize()
                            .font(.custom("tags", size: 8, relativeTo: .caption))
                            .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
                            .foregroundColor(PostTagColor[tag.rawValue])
                    }
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
                    HStack(spacing: 0) {
                        ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                            if lol.count > 0 {
                                Text("A") // 'A' is a tag
                                    .lineLimit(1)
                                    .fixedSize()
                                    .font(.custom("tags", size: 8, relativeTo: .caption))
                                    .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                                    .foregroundColor(PostTagColor[lol.tag])
                            }
                        }
                        macOSWhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
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
