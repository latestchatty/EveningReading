//
//  macOSGuidelinesView.swift
//  iOS
//
//  Created by Chris Hodge on 4/18/21.
//

import SwiftUI

struct macOSGuidelinesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSessionStore: AppSessionStore
    @Binding public var showingGuidelinesView: Bool
    @Binding public var guidelinesAccepted: Bool
    
    func acceptGuidelines() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "GuidelinesAccepted")
        self.showingGuidelinesView = false
        self.guidelinesAccepted = true
    }
    
    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 10)
            ScrollView {
                VStack (alignment: .leading) {
                    VStack (alignment: .leading) {
                        Text("Shack Community Guidelines")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("The Shacknews comments host civil discussions on a variety of topics. Many rule violations will result in the post being nuked without a ban, but the moderator nuking your post will send you a message explaining why your post was nuked. We rely on moderator discretion to help maintain the comments, and topics may be deemed nukable by the moderators in the spirit of maintaining a positive and engaging community (for instance, we may nuke debate threads that’ve turned sour). Some rule violations, however, are taken more seriously (such as posts that are negative and/or hurtful, like personal attacks, trolling, slurs, etc.). These posts will be nuked with a 30-minute cool down ban. Subsequent violations may result in longer periods such as a week, month or in the most extreme cases, permanent. No one can reply to the nuked post, nor will it be visible in the comments. A ban prevents you from posting in the comments for its duration.")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("Some examples of nukable posts include, but are in no way limited to, the following:")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                    }
                    VStack (alignment: .leading) {
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No threats of violence.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No personal attacks or insults.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No obnoxious ascii art.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No overused memes (if you question if it’s overused, it is).").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No spam.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No sharing or linking to pirate sites, leaked or stolen media, and warez. Discussion of piracy as a topic is fine.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No gross, disgusting media including gore.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("Topics that have been done to death at Shacknews ie. tipping, circumcision, etc. Let’s just all agree to disagree.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("Following the same rules we use for racism and homophobia, we'll be nuking posts we feel to be overtly sexist or extremely misogynistic.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("Posts consisting solely of link dumps to porn are subject to the 'contextless post' rule and will be removed.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                    }
                    VStack (alignment: .leading) {
                        Spacer().fixedSize()
                        Text("Complaints about moderation should be done via Shack Message to a moderator.")
                            .font(.body)
                            .bold()
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("Filters")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("Moderators may tag posts based on content. Users can then set filters to customize what posts they will see. Tags exist to categorize, not to punish or critique. Filterable tags include political/religious and not work safe.")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("Hey, where did my post go?")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("You will not see these posts unless you set your filters properly. You can change your filter settings here. Also, your post may have been nuked because an active thread already exists on the topic (there is no ban associated with an organizational nuke).")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                    }
                    VStack (alignment: .leading) {
                        Spacer().fixedSize()
                    }
                }
                .padding(10)
            }
            
            Button(action: acceptGuidelines) {
                Text("Accept").foregroundColor(Color.primary).bold()
            }
            .padding()
        }
    }
}

struct macOSGuidelinesView_Previews: PreviewProvider {
    static var previews: some View {
        macOSGuidelinesView(showingGuidelinesView: Binding.constant(true), guidelinesAccepted: Binding.constant(false))
            .environmentObject(AppSessionStore(service: AuthService()))
    }
}
