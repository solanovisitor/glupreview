//
//  Dashboard.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 03/10/2021.
//

import SwiftUI
import SwiftUICharts

struct Dashboard: View {
    var frame = CGSize(width: 300, height: 300)
    private var rateValue: Int?
    
    @State private var scanningStatus : ScanStatus = ScanStatus.ready
   
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
                VStack {
                    VStack(alignment: .center, spacing: 30) {
                        VStack(alignment:.center) {
                            HStack {
                                Spacer()
                            }
                            ChartView()
                        }
                    }
                    .padding(.top,100)
                    .padding(.bottom,35)
                    if (scanningStatus != ScanStatus.rescan) {
                        VStack(alignment: .center, spacing: 40) {
                            VStack(alignment:.center) {
                                HStack {
                                    Spacer()
                                }
                                Text(scanningStatus.rawValue)
                                    .font(Font.largeTitle)
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing])
                                    .padding(.top,50)
                                    .padding(.bottom,40)
                                Divider().background(Color.white.opacity(0.2))
                                    .padding([.leading,.trailing],50)
                                Button(action: {
                                    scanningStatus = ScanStatus.rescan
                                }) {
                                    Image(scanningStatus == ScanStatus.ready ? "scan_phone" : "scan_complete")
                                        .renderingMode(.original)
                                }
                                .padding(.top,30)
                                Spacer()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2))
                                .background(Color("secondaryBackground").opacity(0.5))
                                .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                                .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30)
                            
                        )
                        .cornerRadius(20)
                        .padding([.leading, .trailing],9)
                    } else {
                        Group {
                            GradientButton(buttonTitle: scanningStatus.rawValue, buttonAction: {
                                scanningStatus = ScanStatus.ready
                            })
                            .padding(.top,30)
                            Spacer()
                        }
                    }
                }
                .padding([.leading, .trailing])
            }
            .toolbar(content: {
                NavigationLink(destination: SettingsView()) {
                    Button(action: {
                        print("button pressed")
                    }) {
                        Image("settings")
                            .renderingMode(.original)
                    }
                }
            })
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

