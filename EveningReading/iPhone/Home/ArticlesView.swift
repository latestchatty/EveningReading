//
//  ArticlesView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct ArticlesView: View {
    @State var articles: [Article] = [Article]()
        
    private func fetchArticles() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        {
            articles = Array(articlesData)
        }
        articles = Array(articlesData)
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
            
            // Content
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        ForEach(articles, id: \.id) { article in
                            ArticleCard(articleTitle: .constant(article.name), articlePreview: .constant(article.preview), articleLink: .constant(article.url))
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
        }
        .onAppear() {
            fetchArticles()
        }
    }
}

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        ArticlesView()
    }
}
