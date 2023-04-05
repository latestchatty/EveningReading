//
//  WhosTaggingView.swift
//  iOS
//
//  Created by Chris Hodge on 8/27/20.
//

import SwiftUI

struct macOSWhosTaggingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding public var showingWhosTaggingView: Bool
    
    @State private var hideRaters: Bool = true
    var postId: Int = -1
    
    private func fetchRaters() {
        chatStore.getRaters(postId: self.postId == -1 ? chatStore.activePostId : self.postId, completionSuccess: {
            self.hideRaters = false
        },
        completionFail: {
            self.hideRaters = false
        }
        )
    }
    
    private func onSheetClosed() {
        self.hideRaters = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
                .sheet(isPresented: $showingWhosTaggingView) {
                    ZStack {
                        // It'd be nice to dynamically size this according to the window size but I don't know how to do that.
                        // GeometryReader will only get the size available to the parent container
                        // So we'll just make it static sized here. Min window size on macOS is 1024x768 so we'll go a little less than that.
                        VStack {}.frame(width: 800, height: 450)
                        VStack {
                            HStack {
                                Button(action: {
                                    self.showingWhosTaggingView = false
                                    self.chatStore.raters.removeAll()
                                }) {
                                    Image(systemName: "xmark")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding()
                                .keyboardShortcut(.cancelAction)
                                
                                Text("Who's Tagging?")
                                    .bold()
                                    .font(.body)
                                Spacer()
                            }
                            .onAppear(perform: fetchRaters)
                            .onDisappear(perform: onSheetClosed)
                            
                            ScrollView {
                                VStack {
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.lol.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("lol")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["lol"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.lol.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["lol"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.inf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("inf")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["inf"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.inf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["inf"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.unf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("unf")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["unf"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.unf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["unf"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.tag.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("tag")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["tag"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.tag.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["tag"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.wtf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("wtf")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["wtf"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.wtf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["wtf"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.wow.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("wow")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["wow"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.wow.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["wow"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    if (chatStore.raters.filter{ $0.tag == String(PostTagKey.aww.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames.count > 0 {
                                        VStack {
                                            HStack {
                                                Text("aww")
                                                    .bold()
                                                    .font(.body)
                                                    .foregroundColor(PostTagColor["aww"])
                                                    .padding(.leading, 10)
                                                Spacer()
                                            }
                                            
                                            Divider()
                                            
                                            
                                            macOSTagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.aww.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["aww"]!)
                                        }.padding(.bottom, 20)
                                    }
                                    
                                    Spacer()
                                }
                            } // ScrollView
                            
                        }
                        .edgesIgnoringSafeArea(.all)
                        .overlay(LoadingView(show: self.$hideRaters, title: .constant("")))
                    }
                    
                } // sheet
        }
        .frame(height: 25)
    }
}

struct macOSTagCloudView: View {
    var tags: [String]
    var tagColor: Color
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag, withColor: tagColor)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String, withColor color: Color) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(color)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 2)
            )
            .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct macOSWhosTaggingView_Previews: PreviewProvider {
    static var previews: some View {
        macOSWhosTaggingView(showingWhosTaggingView: .constant(true))
            .environment(\.colorScheme, .dark)
            .environmentObject(ChatStore(service: ChatService()))
    }
}

