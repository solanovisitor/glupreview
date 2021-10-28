//
//  SignupView.swift
//  Advanced SwiftUI
//
//  Created by Sai Kambampati on 3/22/21.
//

import SwiftUI
import AudioToolbox
import FirebaseAuth
import CryptoKit
import CoreData
import AuthenticationServices
import FirebaseDatabase

struct SignupView: View {
    @State private var email: String = ""
    @State private var editingEmailTextfield = false
    @State private var password: String = ""
    @State private var editingPasswordTextfield = false
    @State private var emailIconBounce: Bool = false
    @State private var passwordIconBounce: Bool = false
    @State private var toggleView: Bool = false
    @State private var signupToggle = true
    
    @State private var showAlertToggle = false
    @State private var fadeImageToggle = true
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var rotationAngle = 0.0
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var signInHandler: SignInWithAppleButtonCoordinator?
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.userSince, ascending: true)],
        animation: .default
    ) private var savedAccounts: FetchedResults<Account>
    
    private let generator = UISelectionFeedbackGenerator()
    
    @State var ref: DatabaseReference = Database.database().reference()
    
    var body: some View {
        ZStack {
            Image(signupToggle ? "background-3" : "background-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(fadeImageToggle ? 0 : 0.5)
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text(signupToggle ? "Sign up" : "Sign in")
                        .font(Font.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("Forecast your blood glucose with AI!")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                            .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                        TextField("Email", text: $email) { isEditing in
                            generator.selectionChanged()
                            editingPasswordTextfield = false
                            editingEmailTextfield = isEditing
                            if isEditing {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                    emailIconBounce.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                        emailIconBounce.toggle()
                                    }
                                }
                            }
                        }
                        .colorScheme(.dark)
                        .foregroundColor(Color.white.opacity(0.7))
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    }
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .stroke(Color.white, lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color("secondaryBackground")
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    
                    HStack(spacing: 12) {
                        TextfieldIcon(iconName: "key.fill", passedImage: .constant(nil), currentlyEditing: $editingPasswordTextfield)
                            .scaleEffect(passwordIconBounce ? 1.2 : 1.0)
                        SecureField("Password", text: $password)
                            .foregroundColor(Color.white.opacity(0.7))
                            .textContentType(.password)
                            .colorScheme(.dark)
                            .autocapitalization(.none)
                    }
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .circular)
                            .stroke(Color.white, lineWidth: 1)
                            .blendMode(.overlay)
                    )
                    .background(
                        Color("secondaryBackground")
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
                    .onTapGesture {
                        generator.selectionChanged()
                        editingPasswordTextfield = true
                        if editingPasswordTextfield {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                passwordIconBounce.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.5)) {
                                    passwordIconBounce.toggle()
                                }
                            }
                        }
                    }
                    
                    GradientButton(buttonTitle: signupToggle ? "Create account" : "Sign in", buttonAction: {
                        generator.selectionChanged()
                        signup()
                    })
                    
                    if signupToggle {
                        Text("By clicking on Sign up, you agree to our Terms of service and Privacy policy.")
                            .font(.footnote)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.white.opacity(0.1))
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            withAnimation(Animation.easeInOut(duration: 0.35)) {
                                fadeImageToggle.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        self.fadeImageToggle.toggle()
                                    }
                                }
                            }
                            
                            withAnimation(Animation.easeInOut(duration: 0.7)) {
                                self.rotationAngle += 180
                                signupToggle.toggle()
                            }
                        }, label: {
                            HStack(spacing: 4) {
                                Text(signupToggle ? "Already have an account?" : "Don't have an account?")
                                    .font(.footnote)
                                    .foregroundColor(Color.white.opacity(0.7))
                                GradientText(text: signupToggle ? "Sign in" : "Sign up")
                                    .font(Font.footnote.bold())
                            }
                        })
                        
                        
                        if !signupToggle {
                            Button(action: {
                                self.sendPasswordResetEmail()
                            }, label: {
                                HStack(spacing: 4) {
                                    Text("Forgot password?")
                                        .font(.footnote)
                                        .foregroundColor(Color.white.opacity(0.7))
                                    GradientText(text: "Reset Password")
                                        .font(Font.footnote.bold())
                                }
                            })
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.white.opacity(0.1))
                            
                            Button(action: {
                                signInHandler = SignInWithAppleButtonCoordinator()
                                signInHandler?.signInWithApple()
                            }, label: {
                                SignInWithAppleButton()
                                    .frame(height: 50)
                                    .cornerRadius(16)
                            })
                        }
                    }
                }
                .padding(20)
            }
            .rotation3DEffect(Angle(degrees: rotationAngle), axis: (x: CGFloat(0), y: CGFloat(1), z: CGFloat(0)))
            .alert(isPresented: $showAlertToggle, content: {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
            })
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2))
                    .background(Color("secondaryBackground").opacity(0.5))
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30)
            )
            .cornerRadius(30)
            .padding(.horizontal)
            .onAppear() {
                UserDefaults.standard.setValue(true, forKey: IsOnboarded_STR)
            }
            .rotation3DEffect(Angle(degrees: rotationAngle), axis: (x: CGFloat(0), y: CGFloat(1), z: CGFloat(0)))
            
        }
        .fullScreenCover(isPresented: $toggleView) {
            if (RCValues.sharedInstance.value(forKey: .modelVersion) == "1.0") {
                ModelDownloadView().environment(\.managedObjectContext, self.viewContext)
            } else {
                Dashboard().environment(\.managedObjectContext, self.viewContext)
            }
        }
    }
    
    func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                alertTitle = "Email Sent!"
                alertMessage = "A password reset email has been sent to \(email)."
                showAlertToggle.toggle()
            } else {
                alertTitle = "Uh-Oh!"
                alertMessage = "The password reset email could not be send. \(error!.localizedDescription)"
                showAlertToggle.toggle()
            }
        }
    }
    
    func signup() {
        if signupToggle {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                guard error == nil else {
                    alertTitle = "Uh-Oh!"
                    alertMessage = error!.localizedDescription
                    showAlertToggle.toggle()
                    return
                }
                if let currentUser = result?.user {
                    saveSessionForUser(isSignUp: true, user: currentUser)
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    alertTitle = "Uh-Oh!"
                    alertMessage = error!.localizedDescription
                    showAlertToggle.toggle()
                }
                if let currentUser = result?.user {
                    saveSessionForUser(isSignUp: false, user: currentUser)
                }
            }
        }
    }
    
    func saveSessionForUser(isSignUp: Bool, user: User){
        if isSignUp {
            let userDic : [String:String] = [
                "name" : user.displayName ?? "",
                "uid" : user.uid,
                "bio" : "",
                "userSince" : Date().description,
                "numberOfCertificates" : "0",
                "proMember" : "0",
                "twitterHandle" : "0",
                "website" : "",
                "profileImage" : "",
            ]
            saveCurrentUserContext(user) {
                UserDefaults.standard.setValue(true, forKey: IsLoggedIn_STR)
                self.ref.child(FIR_User_STR).child(user.uid).setValue(userDic)
                toggleView.toggle()
            }
        } else {
            ref.child("users/\(user.uid)").getData(completion:  { error, snapshot in
                guard error == nil else {
                    alertTitle = "Could not save user data"
                    alertMessage = error!.localizedDescription
                    showAlertToggle.toggle()
                    return;
                }
                saveCurrentUserContext(user) {
                    UserDefaults.standard.setValue(true, forKey: IsLoggedIn_STR)
                    toggleView.toggle()
                }
            });
        }
    }
    func saveCurrentUserContext(_ user : User, completionHandler: @escaping () -> Void){
        if savedAccounts.count == 0 {
            let userDataToSave = Account(context: viewContext)
            userDataToSave.name = user.displayName
            userDataToSave.userID = user.uid
            userDataToSave.bio = nil
            userDataToSave.numberOfCertificates = 0
            userDataToSave.userSince = Date()
            userDataToSave.proMember = false
            userDataToSave.twitterHandle = nil
            userDataToSave.website = nil
            userDataToSave.profileImage = nil
            do {
                try viewContext.save()
                DispatchQueue.main.async {
                    completionHandler()
                }
            } catch let error {
                alertTitle = "Could not save user data"
                alertMessage = error.localizedDescription
                showAlertToggle.toggle()
            }
        } else {
            completionHandler()
        }
        //        do {
        ////            let userDataToSave = UserModel(dic)
        ////            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: userDataToSave, requiringSecureCoding: true)
        ////            UserDefaults.standard.set(encodedData, forKey: CurrentUser_STR)
        ////            UserDefaults.standard.synchronize()
        //
        //        } catch let error {
        //            alertTitle = "Could not save user data"
        //            alertMessage = error.localizedDescription
        //            showAlertToggle.toggle()
        //        }
        
        //        if savedAccounts.count == 0 {
        //            let userDataToSave = Account(context: viewContext)
        //            userDataToSave.name = currentUser.displayName
        //            userDataToSave.userID = currentUser.uid
        //            userDataToSave.bio = nil
        //            userDataToSave.numberOfCertificates = 0
        //            userDataToSave.userSince = Date()
        //            userDataToSave.proMember = false
        //            userDataToSave.twitterHandle = nil
        //            userDataToSave.website = nil
        //            userDataToSave.profileImage = nil
        //            do {
        //                try viewContext.save()
        //                DispatchQueue.main.async {
        //                    showProfileView.toggle()
        //                }
        //            } catch let error {
        //                alertTitle = "Could not save user data"
        //                alertMessage = error.localizedDescription
        //                showAlertToggle.toggle()
        //            }
        //        } else {
        //            showProfileView.toggle()
        //        }
    }
}

struct SignupScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
