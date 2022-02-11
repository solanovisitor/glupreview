//
//  OnboardingView.swift
//  App Onboarding
//
//  Created by Andreas Schultz on 10.08.19.
//  Copyright © 2019 Andreas Schultz. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    
    var subviews = [UIHostingController(rootView: Subview(imageString: "Avatar_1")),
        UIHostingController(rootView: Subview(imageString: "Avatar_2")),
        UIHostingController(rootView: Subview(imageString: "Avatar_3"))]
    
    var titles = ["Hi", "How does it work?", "How to get started?"]
    
    var captions =  ["Welcome to Glupreview!", "We use personalized machine learning for helping you control your blood glucose levels", "You will train your own model by feeding it with your historical glucose measurements"]
    
    @State var currentPageIndex = 0

    var body: some View {
        VStack(alignment: .leading) {
            PageViewController(currentPageIndex: $currentPageIndex, viewControllers: subviews)
                .frame(height: 400)
            Group {
                Text(titles[currentPageIndex])
                    .font(.largeTitle .bold())
                Text(captions[currentPageIndex])
                    .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 300, height: 100, alignment: .leading)
                .lineLimit(nil)
            }
                .padding()
            HStack {
                PageControl(numberOfPages: subviews.count, currentPageIndex: $currentPageIndex)
                    .padding()
                Spacer()
                Button(action: {
                    if self.currentPageIndex+1 == self.subviews.count {
                        self.currentPageIndex = 0
                        print("last index")

                    } else {
                        self.currentPageIndex += 1
                    }
                }) {
                    ButtonContent()
                }
            }
            .padding()
        }
    }
}

struct ButtonContent: View {
    var body: some View {
        Image(systemName: "arrow.right")
        .resizable()
        .foregroundColor(.white)
        .frame(width: 30, height: 30)
        .padding()
        .background(Color.orange)
        .cornerRadius(30)
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif
