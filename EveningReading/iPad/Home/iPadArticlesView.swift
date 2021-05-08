//
//  iPadArticlesView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI


struct iPadArticlesView: View {
    @EnvironmentObject var articleStore: ArticleStore
    
    private func fetchArticles() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil || articleStore.articles.count > 0
        {
            return
        }
        articleStore.getArticles()
    }
    
    private func articlesRow(_ row: Int) -> [Article] {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            return Array(articlesData)
        }
        if articleStore.articles.count > 0 {
            let articlesChunked = articleStore.articles.chunked(into: 5)
            if articlesChunked.count > 0 && row == 1 {
                return articlesChunked[0]
            } else if articlesChunked.count > 1 && row == 2 {
                return articlesChunked[1]
            } else {
                return Array(articleStore.articles)
            }
        } else {
            return Array(articlesData)
        }
    }

    var body: some View {
        VStack {
            // Heading
            VStack {
                HStack {
                    Text("Articles")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .padding(.bottom, -2)
                    Spacer()
                }
                .padding(.horizontal, UIScreen.main.bounds.width <= 375 ? 35 : 20)
            }
            .padding(.top, -50)
            
            // Row 1
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        ForEach(articlesRow(1), id: \.id) { article in
                            ArticleCard(articleTitle: .constant(article.name), articlePreview: .constant(article.preview), articleLink: .constant(article.url))
                                .conditionalModifier(article.id, RedactedModifier())
                                .frame(width: 260.0, height: 180)
                                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
                            Spacer().frame(width: 20)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 20, trailing: 0))
                    Spacer()
                }
                .frame(height: 220)
            }
            .padding(.top, -30)
            
            // Row 2
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        ForEach(articlesRow(2), id: \.id) { article in
                            ArticleCard(articleTitle: .constant(article.name), articlePreview: .constant(article.preview), articleLink: .constant(article.url))
                                .conditionalModifier(article.id, RedactedModifier())
                                .frame(width: 260.0, height: 180)
                                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 10)
                            Spacer().frame(width: 20)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 20, trailing: 0))
                    Spacer()
                }
                .frame(height: 220)
            }
            .padding(.top, -60)
            
        }
        .onAppear(perform: fetchArticles)
    }
}

struct iPadArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        iPadArticlesView()
            .environmentObject(ArticleStore(service: ArticleService()))
    }
}
