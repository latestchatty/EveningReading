//
//  iPadArticlesView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI


struct iPadArticlesView: View {
    @StateObject var articleViewModel = ArticleViewModel()
    
    private func getArticles() {
        if articleViewModel.articles.count > 0
        {
            return
        }
        articleViewModel.getArticles()
    }
    
    private func articlesRow(_ row: Int) -> [Article] {
        // Top 10 articles in two rows
        if articleViewModel.articles.count > 0 {
            let articlesChunked = articleViewModel.articles.chunked(into: 5)
            if articlesChunked.count > 0 && row == 1 {
                return articlesChunked[0]
            } else if articlesChunked.count > 1 && row == 2 {
                return articlesChunked[1]
            } else {
                return Array(articleViewModel.articles)
            }
        } else {
            return Array(RedactedContentLoader.getArticles())
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
                            ArticleCard(articleTitle: article.name, articlePreview: article.preview, articleLink: article.url)
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
                            ArticleCard(articleTitle: article.name, articlePreview: article.preview, articleLink: article.url)
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
        .onAppear(perform: getArticles)
    }
}
