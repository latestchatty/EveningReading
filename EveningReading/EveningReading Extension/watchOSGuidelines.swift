//
//  watchOSGuidelines.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/8/21.
//

import SwiftUI

struct watchOSGuidelines: View {
    @Binding public var showingGuidelinesView: Bool
        
    func acceptGuidelines() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "GuidelinesAccepted")
        self.showingGuidelinesView = false
    }
    
    var body: some View {
        Spacer().frame(width: 0, height: 0)
        .fullScreenCover(isPresented: $showingGuidelinesView) {
            VStack {
                Spacer().frame(width: 0, height: 10)
                ScrollView {
                    VStack (alignment: .leading) {
                        VStack (alignment: .leading) {
                            Text("Shack Community Guidelines")
                                .font(.caption)
                                .bold()
                            Spacer().fixedSize()
                            Text("The Shacknews comments host civil discussions on a variety of topics. Many rule violations will result in the post being nuked without a ban, but the moderator nuking your post will send you a message explaining why your post was nuked. We rely on moderator discretion to help maintain the comments, and topics may be deemed nukable by the moderators in the spirit of maintaining a positive and engaging community (for instance, we may nuke debate threads that’ve turned sour). Some rule violations, however, are taken more seriously (such as posts that are negative and/or hurtful, like personal attacks, trolling, slurs, etc.). These posts will be nuked with a 30-minute cool down ban. Subsequent violations may result in longer periods such as a week, month or in the most extreme cases, permanent. No one can reply to the nuked post, nor will it be visible in the comments. A ban prevents you from posting in the comments for its duration.")
                                .font(.caption2)
                                .fontWeight(.light)
                            Spacer().fixedSize()
                            Text("Some examples of nukable posts include, but are in no way limited to, the following:")
                                .font(.caption2)
                                .fontWeight(.light)
                            Spacer().fixedSize()
                        }
                        VStack (alignment: .leading) {
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No threats of violence.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No personal attacks or insults.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No obnoxious ascii art.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No overused memes (if you question if it’s overused, it is).").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No spam.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No sharing or linking to pirate sites, leaked or stolen media, and warez. Discussion of piracy as a topic is fine.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("No gross, disgusting media including gore.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("Topics that have been done to death at Shacknews ie. tipping, circumcision, etc. Let’s just all agree to disagree.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("Following the same rules we use for racism and homophobia, we'll be nuking posts we feel to be overtly sexist or extremely misogynistic.").font(.caption2).fontWeight(.light)
                            }
                            HStack (alignment: .top) {
                                Text("• ").font(.caption2).fontWeight(.light)
                                Text("Posts consisting solely of link dumps to porn are subject to the 'contextless post' rule and will be removed.").font(.caption2).fontWeight(.light)
                            }
                        }
                        VStack (alignment: .leading) {
                            Spacer().fixedSize()
                            Text("Complaints about moderation should be done via Shack Message to a moderator.")
                                .font(.caption2)
                                .bold()
                            Spacer().fixedSize()
                            Text("Filters")
                                .font(.caption)
                                .bold()
                            Spacer().fixedSize()
                            Text("Moderators may tag posts based on content. Users can then set filters to customize what posts they will see. Tags exist to categorize, not to punish or critique. Filterable tags include political/religious and not work safe.")
                                .font(.caption2)
                                .fontWeight(.light)
                            Spacer().fixedSize()
                            Text("Hey, where did my post go?")
                                .font(.caption)
                                .bold()
                            Spacer().fixedSize()
                            Text("You will not see these posts unless you set your filters properly. You can change your filter settings here. Also, your post may have been nuked because an active thread already exists on the topic (there is no ban associated with an organizational nuke).")
                                .font(.caption2)
                                .fontWeight(.light)
                        }
                        VStack (alignment: .leading) {
                            Spacer().fixedSize()
                        }
                    }
                    .padding(10)
                }
                
                Button(action: acceptGuidelines) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Accept").foregroundColor(Color.primary).bold()
                        Spacer()
                    }
                }.padding().background(Color("AcceptButton")).cornerRadius(4.0).padding(10)
            }
        }
    }
}

struct watchOSGuidelines_Previews: PreviewProvider {
    static var previews: some View {
        watchOSGuidelines(showingGuidelinesView: .constant(true))
    }
}
