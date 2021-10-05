//
//  SettingView.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 05/10/2021.
//

import SwiftUI

struct SettingsView: View {
    @State private var email: String = ""
    @State private var editingEmailTextfield = false
    @State private var emailIconBounce: Bool = false
    @State private var isShowingProfile = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
            Image("ic_back")
                .frame(width: 10, height: 10, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                
                Text("Dashboard").font(Font.body).foregroundColor(.white)
            }
        }
    }
    var body: some View {
        NavigationView{
            ZStack {
                Image("background-2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                Color("secondaryBackground")
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.5)
                VStack (alignment: .leading,spacing:20){
                    Text("Settings").font(Font.title).foregroundColor(.white)
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 12) {
                            TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                                .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                            Text("Privacy Policy").font(Font.body).foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding([.leading,.trailing],10)
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
                    })
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 12) {
                            TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                                .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                            Text("Terms & Conditions").font(Font.body).foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding([.leading,.trailing],10)
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
                    })
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 12) {
                            TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                                .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                            Text("Onboarding screens").font(Font.body).foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding([.leading,.trailing],10)
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
                    })
                    NavigationLink(destination: EditProfile()) {
                        Button(action: {
                            
                        }, label: {
                            HStack(spacing: 12) {
                                TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                                    .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                                Text("Account Info").font(Font.body).foregroundColor(.white)
                                Spacer()
                            }
                            .frame(height: 52)
                            .padding([.leading,.trailing],10)
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
                        })
                    }
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 12) {
                            TextfieldIcon(iconName: "envelope.open.fill", passedImage: .constant(nil), currentlyEditing: $editingEmailTextfield)
                                .scaleEffect(emailIconBounce ? 1.2 : 1.0)
                            Text("Help").font(Font.body).foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding([.leading,.trailing],10)
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
                    })
                }.frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading
                ).padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
