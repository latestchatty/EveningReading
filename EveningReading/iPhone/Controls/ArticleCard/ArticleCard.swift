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
    }
}

struct ArticleCard_Previews: PreviewProvider {
    static var previews: some View {
        ArticleCard(articleTitle: .constant("Lorem Ipsum"), articlePreview: .constant("Omnicos factorial non deposit quid pro quo hic escorol. Olypian quarrels et gorilla congolium sic ad nauseum. Souvlaki ignitus carborundum e pluribus unum."), articleLink: .constant("http://www.shacknews.com"))
    }
}
