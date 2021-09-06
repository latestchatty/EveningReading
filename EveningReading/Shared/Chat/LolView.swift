//
//  LolView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct LolView: View {
    @EnvironmentObject var chatStore: ChatStore
    
    @State var showTagUsers: Bool = false
    
    var lols: [ChatLols] = [ChatLols]()
    var expanded: Bool = false
    var rollup: Bool = false
    var postId: Int = 0
    
    private func getRollupColor(lols: [ChatLols]) -> Color {
        var color = Color.primary
        for lol in lols {
            if lol.count > 0 {
                if color != Color.primary {
                    color = Color.primary
                    break
                }
                color = PostTagColor[lol.tag] ?? Color.primary
            }
        }
        return color
    }
    
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
        if let count = tagCounts[tagType] {
            if tagTypeCount > 3 && count < 2 {
                return true
            }
        }
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
                    .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                    .foregroundColor(PostTagColor[lol.tag])
            }
        }
        #endif
        #if os(OSX)
        if self.rollup {
            HStack {
                WhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
                    .frame(width: 0, height: 0)
                Text(self.lols.filter({$0.count > 0}).count > 0 ? "A" : " ") // 'A' is a tag
                    .lineLimit(1)
                    .fixedSize()
                    .font(.custom("tags", size: 8 + FontSettings.instance.fontOffset, relativeTo: .caption))
                    .foregroundColor(getRollupColor(lols: self.lols))
                    .contextMenu {
                        if self.lols.count > 0 {
                            Button(action: {
                                self.showTagUsers = true
                            }) {
                                Text("Who's Tagging?")
                                Image(systemName: "tag.circle")
                            }
                        }
                    }
            }
            .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
        } else if self.lols.count > 0 {
            if self.expanded {
                // Display as label with count
                HStack {
                    WhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
                        .frame(width: 0, height: 0)
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
                            self.showTagUsers = true
                        }) {
                            Text("Who's Tagging?")
                            Image(systemName: "tag.circle")
                        }
                    }
                }
                .onTapGesture {
                    self.showTagUsers = true
                }
            } else {
                // Display as tag icon
                HStack {
                    WhosTaggingView(showingWhosTaggingView: self.$showTagUsers, postId: self.postId)
                        .frame(width: 0, height: 0)
                    ForEach(self.lols.sorted(by: <), id: \.self) { lol in
                        if lol.count > 0 {
                            Text("A") // 'A' is a tag
                                .lineLimit(1)
                                .fixedSize()
                                .font(.custom("tags", size: 8 + FontSettings.instance.fontOffset, relativeTo: .caption))
                                .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                                .foregroundColor(PostTagColor[lol.tag])
                        }
                    }
                }
                .contextMenu {
                    if self.lols.count > 0 {
                        Button(action: {
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
