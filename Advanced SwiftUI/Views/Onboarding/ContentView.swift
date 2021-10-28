//
//  onboarding_subview.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 30/09/2021.
//

import SwiftUI
enum OnboardViewEnum {
    case first
    case second
    case third
    case fourth
}
struct OnboardContentView: View {
    var imageStr : String!
    var primaryText : String!
    var secondryText : String?
    var isStartVisible : Bool = false
    var onboardView : OnboardViewEnum = OnboardViewEnum.fourth
    
    @State var isMoveToView = false
    @Environment(\.managedObjectContext) private var viewContext
    
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
                        if secondryText != nil {
                            if onboardView == .second {
                                VStack {
                                    Text("We use ")
                                        + Text("personalized ").font(.headline.bold()).foregroundColor(.white)
                                        + Text("machine learning for helping you control your\n")
                                        + Text("blood glucose levels").font(.headline.bold()).foregroundColor(.white)
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding([.leading, .trailing])
                                .padding(.bottom,20)
                            } else if onboardView == .third {
                                VStack {
                                    Text("You will train your own model by ")
                                        + Text("feeding it with your historical glucose measurements")
                                            .font(.headline.bold()).foregroundColor(.white)
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding([.leading, .trailing])
                                .padding(.bottom,20)
                            } else if onboardView == .fourth {
                                VStack {
                                    Text("Click on the button below and ")
                                        + Text("follow the instructions ")
                                        .font(.headline.bold()).foregroundColor(Colors.GradientUpperOrange)
                                        + Text("on our ")
                                        + Text("website ").font(.headline.bold()).foregroundColor(.white)
                                        + Text("to get your model trained and ready to act")
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding([.leading, .trailing])
                                .padding(.bottom,20)
                            }
                        }
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
                    isMoveToView = true
                }).padding([.leading,.trailing],8)
                : nil
        }
        .fullScreenCover(isPresented: $isMoveToView) {
            SignupView()
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardContentView(
            imageStr: "onboarding-1-diamond",
            primaryText: "Hi👋\nWelcome to Gluprview!",
            secondryText: nil,
            onboardView: OnboardViewEnum.first
        )
    }
}
