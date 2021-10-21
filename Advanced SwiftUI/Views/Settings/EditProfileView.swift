//
//  Settings.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 02/10/2021.
//

import SwiftUI

struct EditProfile: View {
    @State private var email: String = ""
    @State private var editingEmailTextfield = false
    @State private var emailIconBounce: Bool = false
    private let generator = UISelectionFeedbackGenerator()
    @State private var editingPasswordTextfield = false

    @State private var bio = "I teach code to designers and design to developers"
    
    var body: some View {
        ZStack {
            Image("background-2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            VStack(alignment: .leading, spacing: nil, content: {
                Text("Profile").font(Font.largeTitle.bold()).foregroundColor(.white).padding(.top,40)
                Text("Manage your Glupreview profile and account").font(.system(size: 15)).foregroundColor(.white.opacity(0.7)).padding(.top, 16)
                HStack(spacing: 12) {
                    TextfieldIcon(iconName: "person.crop.circle", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                        .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                    TextField("Choose Photo", text: $email) { isEditing in
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
                ).padding(.bottom, 8)
                HStack(spacing: 12) {
                    TextfieldIcon(iconName: "textformat.alt", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                        .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                    TextField("Meng To", text: $email) { isEditing in
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
                ).padding(.bottom, 8)
                HStack(spacing: 12) {
                    TextfieldIcon(iconName: "scribble.variable", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                        .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                    TextField("mengto", text: $email) { isEditing in
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
                ).padding(.bottom, 8)
                HStack(spacing: 12) {
                    TextfieldIcon(iconName: "link", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                        .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                    TextField("designcode.io", text: $email) { isEditing in
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
                ).padding(.bottom, 8)
                HStack(spacing: 12) {
                    TextfieldIcon(iconName: "text.justifyleft", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                        .scaleEffect(emailIconBounce ? 1.2 : 1.0).padding(.bottom, 40)
                    MultilineTextView(text: $bio)
                    .colorScheme(.dark)
                    .autocapitalization(.sentences)
                    .textContentType(.none)
                    .lineLimit(4)
                }
                .frame(height: 102)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .circular)
                        .stroke(Color.white, lineWidth: 1)
                        .blendMode(.overlay)
                )
                .background(
                    Color("secondaryBackground")
                        .cornerRadius(16)
                        .opacity(0.8)
                ).padding(.bottom, 8)
                GradientButton(buttonTitle: "Save Settings", buttonAction: {
                    saveSettings()
                }).padding(.top, 8)
                GradientButton(buttonTitle: "Back", buttonAction: {
                    goBack()
                }).padding(.top, 8)
            }).frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal)
        }
        
//        NavigationView {
//
//
//            .navigationBarHidden(true)
//            .navigationBarBackButtonHidden(true)
//        }
    }
    
    func saveSettings() {
        
    }
    
    func goBack() {
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        EditProfile()
    }
}

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        view.textColor = UIColor.white.withAlphaComponent(0.3)
        view.font = UIFont.systemFont(ofSize: 17)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

