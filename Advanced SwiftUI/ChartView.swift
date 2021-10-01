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
    var body: some View {
        VStack {
            LineView(data: demoData, title: "LineChart")
        }

    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
