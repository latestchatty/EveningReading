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
                        Text("Evening Reading App End User License Agreement")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        VStack(alignment: .leading) {
                            Text("This End User License Agreement (“Agreement”) is between you and Evening Reading and governs use of this app made available through the Apple App Store. By installing the Evening Reading App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the Evening Reading App.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("In order to ensure Evening Reading provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content. If you see inappropriate content, please use the “Report as offensive” feature found under each post.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("1. Parties This Agreement is between you and Evening Reading only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. Evening Reading, not Apple, is solely responsible for the Evening Reading App and its content.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("2. Privacy Evening Reading may collect and use information about your usage of the Evening Reading App, including certain types of information from and about your device. Evening Reading may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the Evening Reading App.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("3. Limited License Evening Reading grants you a limited, non-exclusive, non-transferable, revocable license to use theEvening Reading App for your personal, non-commercial purposes. You may only use theEvening Reading App on Apple devices that you own or control and as permitted by the App Store Terms of Service.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                        }
                        VStack(alignment: .leading) {
                            Text("4. Age Restrictions By using the Evening Reading App, you represent and warrant that (a) you are 17 years of age or older and you agree to be bound by this Agreement; (b) if you are under 17 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the Evening Reading App does not violate any applicable law or regulation. Your access to the Evening Reading App may be terminated without warning if Evening Reading believes, in its sole discretion, that you are under the age of 17 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child's use of the Evening Reading App, you agree to be bound by this Agreement in respect to your child's use of the Evening Reading App.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("5. Objectionable Content Policy Content may not be submitted to Evening Reading, who will moderate all content and ultimately decide whether or not to post a submission to the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: (i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (v) gambling, including without limitation, any online casino, sports books, bingo or poker.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("6. Warranty Evening Reading disclaims all warranties about the Evening Reading App to the fullest extent permitted by law. To the extent any warranty exists under law that cannot be disclaimed, Evening Reading, not Apple, shall be solely responsible for such warranty.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("7. Maintenance and Support Evening Reading does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, Evening Reading, not Apple, shall be obligated to furnish any such maintenance or support.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                            Text("8. Product Claims Evening Reading, not Apple, is responsible for addressing any claims by you relating to the Evening Reading App or use of it, including, but not limited to: (i) any product liability claim; (ii) any claim that the Evening Reading App fails to conform to any applicable legal or regulatory requirement; and (iii) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                        }
                        VStack(alignment: .leading) {
                            Text("9. Third Party Intellectual Property Claims Evening Reading shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the Evening Reading App. To the extent Evening Reading is required to provide indemnification by applicable law, Evening Reading, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the Evening Reading App or your use of it infringes any third party intellectual property right.")
                                .font(.body)
                                .fontWeight(.light)
                                .foregroundColor(Color.primary)
                            Spacer().fixedSize()
                        }
                    }
                    VStack (alignment: .leading) {
                        Text("Evening Reading Guidelines")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("The Evening Reading comments host civil discussions on a variety of topics. Many rule violations will result in the post being deleted without a ban, but the moderator deleting your post will send you a message explaining why your post was nuked. We rely on moderator discretion to help maintain the comments, and topics may be deemed objectionable by the moderators in the spirit of maintaining a positive and engaging community (for instance, we may delete contested threads that’ve turned sour). Some rule violations, however, are taken more seriously (such as posts that are negative and/or hurtful, like personal attacks, trolling, slurs, etc.). These posts will be nuked with a 30-minute cool down ban. Subsequent violations may result in longer periods such as a week, month or in the most extreme cases, permanent. No one can reply to the nuked post, nor will it be visible in the comments. A ban prevents you from posting in the comments for its duration.")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                        Spacer().fixedSize()
                        Text("Some examples of objectionable posts include, but are in no way limited to, the following:")
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
                            Text("No sharing or linking to pirate sites, leaked or stolen media, and warez.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("No gross, disgusting media including gore.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("Topics that have been done to death. Let’s just all agree to disagree.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                        }
                        HStack (alignment: .top) {
                            Text("• ").font(.body).fontWeight(.light).foregroundColor(Color.primary)
                            Text("Following the same rules we use for racism and homophobia, we'll be deleting posts we feel to be overtly sexist or extremely misogynistic.").font(.body).fontWeight(.light).foregroundColor(Color.primary)
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
                        Text("You will not see these posts unless you set your filters properly. You can change your filter options in settings. Also, your post may have been deleted because an active thread already exists on the topic (there is no ban associated with an organizational delete).")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(Color.primary)
                    }
                    VStack (alignment: .leading) {
                        Spacer().fixedSize()
                    }
                    VStack (alignment: .center) {
                        Button(action: acceptGuidelines) {
                            Text("Accept").foregroundColor(Color.primary).bold()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(10)
            }
            
            /*
            Button(action: acceptGuidelines) {
                Text("Accept").foregroundColor(Color.primary).bold()
            }
            .padding()
            */
        }
    }
}
