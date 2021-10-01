//
//  ScanView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 01/10/21.
//

import SwiftUI

struct ScanView: View {
    @State private var buttonToggle = false

    var body: some View {
        ZStack {
            Image("background-1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            Color("secondaryBackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            VStack {
                VStack(alignment: .center, spacing: 80) {
                    ChartView()
                    ScanButton(buttonTitle: "Scan!")
            }
                .padding(20)
        }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2))
                    .background(Color("secondaryBackground").opacity(0.5))
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .shadow(color: Color("shadowColor").opacity(0.5), radius: 60, x: 0, y: 30))
            .cornerRadius(30)
            .padding(.horizontal)
        }
    
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
        }
    }
}

