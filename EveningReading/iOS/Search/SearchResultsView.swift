//
//  SearchResultsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var appService: AppService
    @EnvironmentObject var chatService: ChatService
    
    var terms: String
    var author: String
    var parentAuthor: String
    
    @State private var searchResults: [SearchChatPosts] = []
    @State private var showingLoading: Bool = true
    
    private func search() {
        chatService.search(terms: self.terms, author: self.author, parentAuthor: self.parentAuthor, completion: {
                searchResults = chatService.searchResults
                showingLoading = false
            })
    }
    
    var body: some View {
        VStack {            
            if !showingLoading && searchResults.count < 1 {
                LazyVStack {
                    Spacer()
                    Text("No Results.")
                        .font(.body)
                        .bold()
                        .foregroundColor(Color("NoDataLabel"))
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchResults, id: \.id) { post in
                            NavigationLink(destination: ThreadDetailView(threadId: post.threadId, postId: post.id, replyCount: -1, isSearchResult: true)) {
                                HStack {
                                    VStack (alignment: .leading) {
                                        
                                        // AUthor and time ago
                                        HStack (alignment: .center) {
                                            AuthorNameView(name: post.author, postId: post.id)
                                            
                                            Spacer()
                                            
                                            Text(post.date.getTimeAgo())
                                                .font(.footnote)
                                                .foregroundColor(Color(UIColor.systemGray))
                                        }
                                        .frame(minHeight: 20)
                                        .offset(y: 5)

                                        // Post body and chat bubble
                                        ZStack {
                                            HStack (alignment: .top) {
                                                Text(post.body.getPreview)
                                                    .font(.callout)
                                                    .foregroundColor(Color(UIColor.label))
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(appService.abbreviateThreads ? 3 : 8)
                                                    .frame(minHeight: 30)
                                                    .padding(10)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.callout)
                                                    .foregroundColor(Color(UIColor.systemGray))
                                                    .padding(.trailing, 20)
                                                    .padding(.top, 22)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(RoundedCornersView(color: Color("ChatBubblePrimary")))
                                        
                                    }
                                }
                                .padding(.horizontal, 10)
                                //.padding(.top, 5)
                            }
                        }
                    }
                    
                    VStack {
                        Spacer().frame(maxWidth: .infinity).frame(height: 30)
                    }
                    
                }
            }
        }
        .overlay(LoadingView(show: self.$showingLoading))
        .disabled(self.showingLoading)
        .onAppear(perform: search)
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Results", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}
