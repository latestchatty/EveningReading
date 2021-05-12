//
//  SearchResultsView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    
    var terms: String
    var author: String
    var parentAuthor: String
    
    @State private var searchResults: [SearchChatPosts] = []
    @State private var showingLoading: Bool = true
    
    private func search() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            showingLoading = false
            searchResults = searchData.posts
            return
        }
        chatStore.search(terms: self.terms, author: self.author, parentAuthor: self.parentAuthor, completion: {
                searchResults = chatStore.searchResults
                showingLoading = false
            })
    }
    
    var body: some View {
        VStack {            
            //GoToPostView()
            
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
                    LazyVStack {
                        ForEach(searchResults, id: \.id) { post in
                            NavigationLink(destination: ThreadDetailView(threadId: .constant(post.threadId), postId: .constant(post.id))) {
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
                                        
                                        // Post body and chat bubble
                                        ZStack {
                                            HStack (alignment: .top) {
                                                Text(post.body.getPreview)
                                                    .font(.callout)
                                                    .foregroundColor(Color(UIColor.label))
                                                    .lineLimit(appSessionStore.abbreviateThreads ? 3 : 8)
                                                    .frame(minHeight: 30)
                                                    .padding(10)
                                                    .padding(.top, 10)
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
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
        }
        .overlay(LoadingView(show: self.$showingLoading, title: .constant("")))
        .disabled(self.showingLoading)
        .onAppear(perform: search)
        .background(Color("PrimaryBackground").frame(height: 2600).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Inbox", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 26, height: 16))
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(terms: "", author: "", parentAuthor: "")
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
    }
}
