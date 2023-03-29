//
//  WhosTaggingView.swift
//  iOS
//
//  Created by Chris Hodge on 8/27/20.
//

import SwiftUI

struct WhosTaggingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var chatStore: ChatStore
    
    @Binding public var showingWhosTaggingView: Bool
    
    @State private var hideRaters: Bool = true
    
    private func fetchRaters() {
        chatStore.getRaters(postId: chatStore.activePostId, completionSuccess: {
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
        //VStack {
            Spacer().frame(width: 0, height: 0)
            .sheet(isPresented: $showingWhosTaggingView) {
                VStack {
                    ScrollView {
                        HStack {
                            Spacer()
                            Button(action: { self.showingWhosTaggingView = false }) {
                                Rectangle()
                                    .foregroundColor(Color(UIColor.systemFill))
                                    .frame(width: 40, height: 5)
                                    .cornerRadius(3)
                                    .opacity(0.5)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .onAppear(perform: fetchRaters)
                        .onDisappear(perform: onSheetClosed)

                        Text("Who's Tagging?")
                            .bold()
                            .font(.body)
                            .foregroundColor(Color(UIColor.label))
                            .padding(.horizontal, 20)
                            .padding(.bottom, self.hideRaters ? 2600 : 1e-10)
                    
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
                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.lol.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["lol"]!)
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
                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.inf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["inf"]!)
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

                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.unf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["unf"]!)
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
                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.tag.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["tag"]!)
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
                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.wtf.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["wtf"]!)
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
                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.wow.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["wow"]!)
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

                                    
                                    TagCloudView(tags: (chatStore.raters.filter{ $0.tag == String(PostTagKey.aww.rawValue) }.first ?? Raters(thread_id: "0", user_ids: [], usernames: [], tag: "")).usernames, tagColor: PostTagColor["aww"]!)
                                }.padding(.bottom, 20)
                            }
                    
                            Spacer()
                        }
                    } // ScrollView
                    
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(LoadingView(show: self.$hideRaters, title: .constant("")))
            } // sheet
        //}
        //.frame(height: 25)
    }
}

struct TagCloudView: View {
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

struct WhosTaggingView_Previews: PreviewProvider {
    static var previews: some View {
        WhosTaggingView(showingWhosTaggingView: .constant(true))
            .environment(\.colorScheme, .dark)
            .environmentObject(ChatStore(service: ChatService()))
    }
}

