//
//  LoadingView.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI

struct LoadingView : View {
    @Binding public var show: Bool
    @Binding public var title: String
    
    var body: some View {
        if show {
            ProgressView(title)
                .frame(width: 120,
                       height: 120)
                .background(BlurView(style: .systemUltraThinMaterial))
                .foregroundColor(Color.primary)
                .cornerRadius(20)
        } else {
            EmptyView()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(show: .constant(true), title: .constant("Loading..."))
    }
}