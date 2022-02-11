//
//  onboarding.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 30/09/2021.
//

import SwiftUI

struct Onboarding: View {
    @State private var currentTab = 0
    var body: some View {
        ZStack {
            Image("background-2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            TabView(selection: $currentTab,
                            content:  {
                                OnboardContentView(
                                    imageStr: "onboarding-1-diamond",
                                    primaryText: "Hi👋\nWelcome to Gluprview!",
                                    secondryText: nil,
                                    onboardView: OnboardViewEnum.first)
                                    .tag(0)
                                OnboardContentView(
                                    imageStr: "onboarding-2-magnify",
                                    primaryText: "How does it work?",
                                    secondryText: "We use personalized machine learning for helping you control your blood glucose levels",
                                    onboardView: OnboardViewEnum.second)
                                    .tag(1)
                                OnboardContentView(
                                    imageStr: "onboarding-3-arrow",
                                    primaryText: "How to get started?",
                                    secondryText: "You will train your own model by feeding it with your historical glucose measurements",
                                    onboardView: OnboardViewEnum.second)
                                    .tag(2)
                                OnboardContentView(
                                    imageStr: "onboarding-4-sun",
                                    primaryText: "Train your model!",
                                    secondryText: "Click on the button below and follow the instructions on our website to get your model trained and ready to act",isStartVisible: true,onboardView: OnboardViewEnum.fourth)
                                    .tag(3)
                            })
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding(.bottom,50)
            
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
