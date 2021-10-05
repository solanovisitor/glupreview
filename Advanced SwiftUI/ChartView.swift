//
//  ChartView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 01/10/21.
//

import SwiftUI
import SwiftUICharts

struct ChartView:View {
    var demoData: [Double] = [132, 125, 120, 120, 118, 111, 104,  99,  94,  91,  89,  84]
    let chartStyle = ChartStyle(backgroundColor: Color("secondaryBackground").opacity(0.1), accentColor: Color.white.opacity(0.5), secondGradientColor: Color.orange, textColor: Color.white, legendTextColor: Color.white, dropShadowColor: Color.gray)
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(#colorLiteral(red: 0.10078595578670502, green: 0.06947916746139526, blue: 0.24166665971279144, alpha: 0.8999999761581421)))
                        LineView(data: demoData, title: "Glucose (mg/dL)", style: chartStyle)
                            .padding(30)
                    }
                    
                }.frame(maxWidth: geometry.size.width)
                .frame(height: geometry.size.height + 40)
                .frame(alignment: .center)
            }
        }.frame(width: 380, height: 350)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
