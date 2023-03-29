//
//  FavoriteUsersView.swift
//  EveningReading (iOS)
//
//  Created by Chris Hodge on 3/29/23.
//

import SwiftUI

struct FavoriteUsersView: View {
    @EnvironmentObject var appSessionStore: AppSessionStore
    
    @State private var showingDeleteAlert = false
    @State private var currentFavorite = ""
    
    var body: some View {
        ScrollView {
            VStack {
                if appSessionStore.favoriteAuthors.filter { $0 != "" }.isEmpty {
                    HStack {
                        Text("No favorites, long press a post to add users.")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color("NoDataLabel"))
                    }
                }
                ForEach(appSessionStore.favoriteAuthors.filter { $0 != "" }, id: \.self) { favorite in
                    HStack {
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
            return Alert(title: Text("Remove Favorite?"), message: Text(""), primaryButton: primaryButton, secondaryButton: secondaryButton)
        }
        .navigationBarTitle("Favorite Users", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16))
    }
    
    func deleteFavorite() {
        appSessionStore.favoriteAuthors = appSessionStore.favoriteAuthors.filter { $0 != currentFavorite }
    }
}

struct FavoriteUsersView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteUsersView()
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
