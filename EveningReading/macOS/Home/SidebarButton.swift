//
//  SidebarButton.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/3/21.
//

import SwiftUI

struct SidebarButton: View {
    @Binding var text: String
    @Binding var imageName: String
    @Binding var selected: Bool
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                Label(self.text, systemImage: self.imageName)
                    .padding(.leading, 5)
                Spacer()
            }
            .frame(minHeight: 24)
            .frame(maxWidth: .infinity)
            .background(self.selected ? Color("macOSSidebarHighlight") : Color.clear)
            .cornerRadius(5)
        }
    }
}

struct SidebarButton_Previews: PreviewProvider {
    static var previews: some View {
        SidebarButton(text: .constant("Chat"), imageName: .constant("text.bubble"), selected: .constant(true))
    }
}
