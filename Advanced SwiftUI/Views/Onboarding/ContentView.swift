//
//  onboarding_subview.swift
//  Advanced SwiftUI
//
//  Created by Sulaman Khan on 30/09/2021.
//

import SwiftUI

struct OnboardContentView: View {
    var imageStr : String!
    var primaryText : String!
    var secondryText : String?
    var isStartVisible : Bool = false
    var body: some View {
        VStack {
            VStack {
                VStack(alignment: .center, spacing: 30) {
                    Image(imageStr)
                        .resizable()
                            .frame(width: 86, height: 98)
                        .padding(.top,50)
                    VStack(alignment:.leading) {
                        HStack {
                            Spacer()
                          }
                        Text(primaryText)
                            .font(Font.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                            .padding(.bottom, secondryText != nil ? 10 : 50)
                        secondryText != nil
                            ? Text(secondryText!)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding([.leading, .trailing])
                            .padding(.bottom,50)
                            : nil
                    }
                }
                .padding(.horizontal)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2))
                    .background(Color("secondaryBackground").opacity(0.5))
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30)
                
            )
            .cornerRadius(30)
            .padding([.leading, .trailing])
            isStartVisible
                ? GradientButton(buttonTitle: "Start", buttonAction: {
                    //                        signup()
                }).padding([.leading,.trailing],8)
                : nil
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardContentView(
            imageStr: "onboarding-1-diamond",
            primaryText: "Hi👋\nWelcome to Gluprview!",
            secondryText: "We use personalized machine learning for helping you control your blood glucose levels")
    }
}
