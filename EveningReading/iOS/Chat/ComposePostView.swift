//
//  ComposePostView.swift
//  iOS
//
//  Created by Chris Hodge on 7/7/20.
//

import SwiftUI
import Photos

struct ComposePostView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appSessionStore: AppSessionStore
    @EnvironmentObject var chatStore: ChatStore
    @EnvironmentObject var shackTags: ShackTags
    @EnvironmentObject var notifications: Notifications
    
    public var isRootPost: Bool = false
    public var postId: Int = 0
    
    @State private var postBody = ""
    @State private var postStyle = UIFont.TextStyle.body

    @State private var showingComposeSheet = false

    @State private var showingLoading = false
    @State private var loadingMessage = "Loading"

    @State private var showingImageSheet = false
    @State private var uploadImage: UIImage?
    @State private var uploadImageFail = false

    @State private var showingSubmitAlert = false
    @State private var showingSubmitError = false
    
    @State private var showingTagMenu = false
    
    private func submitPost() {
        self.loadingMessage = "Submitting"
        self.showingLoading = true
        self.chatStore.didSubmitPost = true
        
        if self.isRootPost {
            self.chatStore.didSubmitNewThread = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                self.chatStore.didGetChatStart = true
            }
        } else {
            self.chatStore.didGetThreadStart = true
        }

        // Let the loading indicator show for at least a short time
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.chatStore.submitPost(postBody: self.postBody, postId: self.postId)
            ShackTags.shared.taggedText = ""
        }
        
        //TODO: Can this use .asyncAfterPostDelay extension? Why is it so long?
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8)) {
            self.chatStore.getThread()
        }
    }

    private func showImageSheet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                //handle authorized status
                self.showingImageSheet = true
                break
            case .denied, .restricted :
                //handle denied status
                break
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        // as above
                        self.showingImageSheet = true
                    case .denied, .restricted:
                        // as above
                        print("denied access to photos")
                        break
                    case .notDetermined:
                        // won't happen but still
                        print("undetermined photo access status")
                        break
                    case .limited:
                        print("unknown photo access error")
                    @unknown default:
                        print("unknown photo access error")
                    }
                }
            case .limited:
                print("unknown photo access error")
            @unknown default:
                print("unknown photo access error")
            }
        }
    }
    
    private func getBase64Image(image: UIImage, complete: @escaping (String?) -> ()) {
        DispatchQueue.main.async {
            let imageData = image.pngData()
            let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)
            complete(base64Image)
        }
    }
    
    private func uploadImageToImgur(image: UIImage) {
        if let imgurKey = Bundle.main.infoDictionary?["IMGUR_KEY"] as? String {
            var resizedImage = image
            let imageSize = image.getSizeIn(.megabyte)
            
            if imageSize > 9.0 {
                resizedImage = image.resized(withPercentage: 0.5) ?? image
            }
            
            getBase64Image(image: resizedImage) { base64Image in
                let boundary = "Boundary-\(UUID().uuidString)"

                var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
                request.addValue("Client-ID \(imgurKey)", forHTTPHeaderField: "Authorization")
                request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                request.httpMethod = "POST"

                var body = ""
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"image\""
                body += "\r\n\r\n\(base64Image ?? "")\r\n"
                body += "--\(boundary)--\r\n"
                let postData = body.data(using: .utf8)

                request.httpBody = postData
                request.timeoutInterval = 60

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        self.showingLoading = false
                        self.uploadImageFail = true
                        return
                    }
                    guard let response = response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
                        self.showingLoading = false
                        self.uploadImageFail = true
                        return
                    }
                    if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                        let parsedResult: [String: AnyObject]
                        do {
                            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                            if let dataJson = parsedResult["data"] as? [String: Any] {
                                self.postBody += "\(dataJson["link"] as? String ?? "[Error Uploading Image]")"
                                self.showingLoading = false
                                self.uploadImageFail = false
                            }
                        } catch {
                            self.uploadImageFail = true
                        }
                    }
                }.resume()
            }
        } else {
            // NO API KEY
            self.uploadImageFail = true
        }
    }
    
    private func clearComposeSheet() {
        DispatchQueue.main.async {
            chatStore.submitPostSuccessMessage = ""
            chatStore.submitPostErrorMessage = ""
            self.postBody = ""
            ShackTags.shared.taggedText = ""
            self.showingLoading = false
            self.uploadImageFail = false
            self.showingComposeSheet = false
            self.showingTagMenu = false
        }
    }
    
    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 0)

            // Compose Post Sheet
            .sheet(isPresented: self.$showingComposeSheet,
               onDismiss: {
                    print("Modal Dismissed")
               }) {
                VStack {
                    ZStack {
                        
                        // Heads up if it's going to be a new thread
                        if postId == 0 {
                            HStack {
                                Spacer()
                                Text("New Thread")
                                    .font(.body)
                                    .padding(.top, 10)
                                Spacer()
                            }
                        }
                        
                        // Buttons
                        HStack {
                            Spacer().frame(width: 10)
                            
                            // Bail!
                            Button("Cancel") {
                                clearComposeSheet()
                            }
                            
                            Spacer()

                            // Imgur Button
                            Button(action: {
                                print("got here")
                                if self.showingLoading || self.showingTagMenu {
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.showingComposeSheet = false
                                    self.uploadImageFail = false
                                    showImageSheet()
                                }
                            }) {
                                if self.uploadImageFail {
                                    Image(systemName: "photo")
                                        .foregroundColor(self.showingLoading ? Color(UIColor.systemGray3) : Color(UIColor.link))
                                        .overlay(Image(systemName: "exclamationmark").scaleEffect(0.75).padding(.top, -5).padding(.leading, 25).foregroundColor(Color(UIColor.systemRed)), alignment: .top)
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(self.showingLoading ? Color(UIColor.systemGray3) : Color(UIColor.link))
                                }
                            }
                            
                            Spacer().frame(width: 10)
                            
                            // Submit Post
                            Button("Submit") {
                                if self.showingLoading || self.postBody.count < 5 || self.showingTagMenu {
                                    return
                                }
                                withAnimation(.easeIn(duration: 0.05)) {
                                    self.showingSubmitAlert = true
                                }
                            }
                            .frame(width: 70, height: 30)
                            .foregroundColor(self.showingLoading || self.postBody.count < 5 ? Color(UIColor.systemGray3) : Color(UIColor.link))
                            
                            Spacer().frame(width: 10)
                        }
                        .padding(.top, 10)
                        
                    }
                    
                    // TextEditor
                    ZStack {
                        ShackTagsTextView(text: self.$postBody, textStyle: self.$postStyle, doTagText: self.$showingTagMenu)
                            .border(Color(UIColor.systemGray5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

                        /*
                        // no way to change the background yet :(
                        if appSessionStore.isDarkMode {
                            TextEditor(text: self.$postBody)
                                .border(Color(UIColor.systemGray5))
                                .cornerRadius(4.0)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        } else if colorScheme == .light {
                            TextEditor(text: self.$postBody)
                                .border(Color(UIColor.systemGray5))
                                .cornerRadius(4.0)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        } else {
                            TextEditor(text: self.$postBody)
                                .border(Color(UIColor.systemGray5))
                                .cornerRadius(4.0)
                                .colorInvert()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        }
                        */

                        // Loading indicator
                        LoadingView(show: self.$showingLoading, title: self.$loadingMessage)
                        
                        // Dim the text editor
                        if self.showingLoading || self.showingSubmitAlert {
                            Rectangle()
                                .fill(Color(UIColor.systemGray))
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                                .padding(.all, 5)
                                .cornerRadius(5)
                                .opacity(0.1)
                        }
                        
                        // Shack tags
                        TagTextView(shown: self.$showingTagMenu)
                        
                        // Can't show a real alert on top of a sheet
                        AlertView(shown: self.$showingSubmitAlert, alertAction: .constant(.others), message: "Submit post?", cancelOnly: false, confirmAction: {
                            self.submitPost()
                        })
                        
                        // Some kind of posting error
                        AlertView(shown: self.$showingSubmitError, alertAction: .constant(.others), message: "Error Posting", cancelOnly: true, confirmAction: {
                            self.chatStore.submitPostSuccessMessage = ""
                            self.chatStore.submitPostErrorMessage = ""
                        })
                    }
                    Spacer()                    
                }
                //.allowAutoDismiss { false }
                .background(appSessionStore.isDarkMode ? Color("PrimaryBackgroundDarkMode").frame(height: 2600).offset(y: -80) : Color.clear.frame(height: 2600).offset(y: -80))
            }
            // End Compose Post Sheet
            
            // Image Picker Sheet
            .sheet(isPresented: $showingImageSheet,
                   onDismiss: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
                            self.showingComposeSheet = true
                            if self.uploadImage != nil {
                                uploadImageToImgur(image: self.uploadImage!)
                            } else {
                                self.uploadImageFail = false
                            }
                        }
                   }) {
                ImagePickerView(sourceType: .photoLibrary) { image in
                    self.uploadImage = image
                    self.showingImageSheet = false
                    self.showingLoading = true
                    self.loadingMessage = "Uploading"
                }
            }
            
            // Post Success
            .onReceive(self.chatStore.$submitPostSuccessMessage) { successMsg in
                if successMsg != "" {
                    DispatchQueue.main.async {
                        self.chatStore.submitPostSuccessMessage = ""
                        self.chatStore.submitPostErrorMessage = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                        self.postBody = ""
                        self.showingLoading = false
                        self.showingComposeSheet = false
                    }
                }
            }
            
            // Post Fail
            .onReceive(self.chatStore.$submitPostErrorMessage) { errorMsg in
                if errorMsg != "" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                        self.showingLoading = false
                        self.showingSubmitError = true
                    }
                }
            }

            // Tag some text
            .onReceive(self.shackTags.$doTagText) { value in
                if value {
                    self.showingTagMenu = true
                }
            }
            
            // If shack tags were added
            .onReceive(ShackTags.shared.$taggedText) { value in
                if value != "" {
                    self.postBody = value
                }
            }
                
            // If push notification tapped
            .onReceive(notifications.$notificationData) { value in
                if value != nil {
                    clearComposeSheet()
                }
            }
            
            // Hide TagTextView
            .onAppear() {
                self.showingTagMenu = false
            }
            
            // Button style is different depending on context
            if self.appSessionStore.isSignedIn || ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
                Button(action: {
                    DispatchQueue.main.async {
                        self.showingComposeSheet = true
                    }
                }) {
                    ZStack {
                        if !self.isRootPost {
                            Image(systemName: "circle.fill")
                                .font(.title)
                                .foregroundColor(Color("ActionButton"))
                                .shadow(color: Color("ActionButtonShadow"), radius: 4, x: 0, y: 0)
                        }
                        Image(systemName: self.isRootPost ? "square.and.pencil" : "arrowshape.turn.up.left")
                            .imageScale(!self.isRootPost ? .medium : .large)
                            .foregroundColor(self.colorScheme == .dark ? Color(UIColor.white) : Color(UIColor.systemBlue))
                    }
                }
            }
            
        }
    }
}

struct ComposePostView_Previews: PreviewProvider {
    static var previews: some View {
        ComposePostView(isRootPost: false)
            .environmentObject(AppSessionStore(service: AuthService()))
            .environmentObject(ChatStore(service: ChatService()))
            .environmentObject(ShackTags())
            .environmentObject(Notifications())
    }
}
