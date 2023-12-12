//
//  SearchView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import SwiftUI

struct SearchView: View {
    public var populateTerms: String = ""
    public var populateAuthor: String = ""
    public var populateParent: String = ""
    @State var terms = ""
    @State var author = ""
    @State var parent = ""
    @State var clearCriteria = true
    @State var showingNoCriteraAlert = false
    
    func searchAppear() {
        if self.populateTerms != "" {
            self.terms = self.populateTerms
        }
        if self.populateAuthor != "" {
            self.author = self.populateAuthor
        }
        if self.populateParent != "" {
            self.parent = self.populateParent
        }
    }
    
    func searchDisappear() {
        if self.clearCriteria {
            self.terms = ""
            self.author = ""
            self.parent = ""
        }
    }
    
    func search() {
        if self.terms != "" || self.author != "" || self.parent != "" {
            self.clearCriteria = false
            self.showingResults = true
        } else {
            self.showingNoCriteraAlert = true
        }
    }
    
    @State private var showingResults = false
    
    var body: some View {
        VStack {            
            NavigationLink(destination: SearchResultsView(terms: self.terms, author: self.author, parentAuthor: self.parent),
                isActive: self.$showingResults) {
                EmptyView()
            }
            
            // General terms
            HStack(alignment: .center) {
                Text("Terms")
                    .frame(width: 80)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                TextField("", text: self.$terms)
                    .textInputAutocapitalization(.never)
                    .padding(10)
                    .background(Color("SearchField"))
                    .cornerRadius(4.0)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            }.padding(.top, 10)

            // Author
            HStack(alignment: .center) {
                Text("Author")
                    .frame(width: 80)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                TextField("", text: self.$author)
                    .textInputAutocapitalization(.never)
                    .padding(10)
                    .background(Color("SearchField"))
                    .cornerRadius(4.0)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            }
            
            // Parent Author
            HStack(alignment: .center) {
                Text("Parent")
                    .frame(width: 80)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                TextField("", text: self.$parent)
                    .textInputAutocapitalization(.never)
                    .padding(10)
                    .background(Color("SearchField"))
                    .cornerRadius(4.0)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            }.padding(.bottom, 5)
            
            Button(action: self.search) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Search").foregroundColor(Color.primary).bold()
                    Spacer()
                }
            }.padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)).background(Color("SearchButton")).cornerRadius(4.0)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("PrimaryBackground").frame(height: BackgroundHeight).offset(y: -80))
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Search", displayMode: .inline)
        .navigationBarItems(leading: Spacer().frame(width: 16, height: 16))
        .alert(isPresented: self.$showingNoCriteraAlert) {
            Alert(title: Text("No Criteria"), message: Text("Enter search criteria"), dismissButton: .default(Text("OK")))
        }
    }
}
