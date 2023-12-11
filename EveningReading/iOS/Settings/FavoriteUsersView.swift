//
//  FavoriteUsersView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 3/29/23.
//

import SwiftUI

struct FavoriteUsersView: View {
    @EnvironmentObject var appSession: AppSession
    
    @State private var showingDeleteAlert = false
    @State private var currentFavorite = ""
    
    var body: some View {
        ScrollView {
            VStack {
                if appSession.favoriteAuthors.filter({ $0 != "" }).isEmpty {
                    HStack {
                        Text("No favorites, long press a post to add users.")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color("NoDataLabel"))
                            .padding(.top, 20)
                    }
                }
                ForEach(appSession.favoriteAuthors.filter { $0 != "" }, id: \.self) { favorite in
                    HStack {
                        Image(systemName: "star")
                            .imageScale(.medium)
                            .foregroundColor(Color(UIColor.systemRed))

                        Text(favorite)
                            .lineLimit(1)
                        Spacer()
                        Button(action: {
                            self.currentFavorite = favorite
                            self.showingDeleteAlert = true
                        }) {
                            Circle().fill(Color.gray).frame(width: 25, height: 25)
                                .overlay(Image(systemName: "minus").resizable().aspectRatio(contentMode: .fit).foregroundColor(Color.black).frame(width: 10))
                        }
                    }
                    .padding(.horizontal)
                    Divider().overlay(.gray)
                }
            }
        }
        .alert(isPresented: self.$showingDeleteAlert) { () -> Alert in
            let primaryButton = Alert.Button.default(Text("Cancel")) {
                self.showingDeleteAlert = false
            }
            let secondaryButton = Alert.Button.cancel(Text("OK")) {
                deleteFavorite()
            }
            return Alert(title: Text("Remove User?"), message: Text(""), primaryButton: primaryButton, secondaryButton: secondaryButton)
        }
        .navigationBarTitle("Favorite Users", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16))
    }
    
    func deleteFavorite() {
        appSession.favoriteAuthors = appSession.favoriteAuthors.filter { $0 != currentFavorite }
    }
}
