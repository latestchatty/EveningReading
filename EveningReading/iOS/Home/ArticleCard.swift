//
//  ArticleCard.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct ArticleCard: View {
    @Binding var articleTitle: String
    @Binding var articlePreview: String
    @Binding var articleLink: String
    
    @State var showingArticleSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(articleTitle)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(width: 180, alignment: .leading)
                .padding(20)

                Spacer()
                
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.white)
                    .padding(.trailing, 20)
            }
            
            Text(articlePreview + "\n\n\n")
                .font(.subheadline)
                .foregroundColor(Color.white)
                .lineLimit(4)
                .padding(.horizontal, 20.0)
                .padding(.bottom, 20.0)

        }
        .background(Color("ArticleCardBackground"))
        .cornerRadius(10)
        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
            self.showingArticleSheet = true
        })
        .safariView(isPresented: self.$showingArticleSheet) {
            SafariView(
                url: URL(string: articleLink)!,
                configuration: SafariView.Configuration(
                    entersReaderIfAvailable: false,
                    barCollapsingEnabled: true
                )
            )
            .preferredBarAccentColor(.clear)
            .preferredControlAccentColor(.accentColor)
            .dismissButtonStyle(.done)
        }
    }
}
