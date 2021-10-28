//
//  ChartView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 01/10/21.
//

import SwiftUI
import SwiftUICharts
import CoreML
struct ChartView:View {
    
//    let chartStyle = ChartStyle(backgroundColor: Color("secondaryBackground").opacity(0.1), accentColor: Color.white.opacity(0.5), secondGradientColor: Color.orange, textColor: Color.white, legendTextColor: Color.white, dropShadowColor: Color.gray)
    let data: LineChartData = weekOfData()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(#colorLiteral(red: 0.10078595578670502, green: 0.06947916746139526, blue: 0.24166665971279144, alpha: 0.8999999761581421)))
                        LineChart(chartData: data)
                            //                            .extraLine(chartData: data,
                            //                                       legendTitle: "Test",
                            //                                       datapoints: extraLineData,
                            //                                       style: extraLineStyle)
                            .pointMarkers(chartData: data)
                            .touchOverlay(chartData: data, specifier: "%.0f")
                            //                            .yAxisPOI(chartData: data,
                            //                                      markerName: "Step Count Aim",
                            //                                      markerValue: 15_000,
                            //                                      labelPosition: .center(specifier: "%.0f"),
                            //                                      labelColour: Color.black,
                            //                                      labelBackground: Color(red: 1.0, green: 0.75, blue: 0.25),
                            //                                      lineColour: Color(red: 1.0, green: 0.75, blue: 0.25),
                            //                                      strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                            //                            .yAxisPOI(chartData: data,
                            //                                      markerName: "Minimum Recommended",
                            //                                      markerValue: 10_000,
                            //                                      labelPosition: .center(specifier: "%.0f"),
                            //                                      labelColour: Color.white,
                            //                                      labelBackground: Color(red: 0.25, green: 0.75, blue: 1.0),
                            //                                      lineColour: Color(red: 0.25, green: 0.75, blue: 1.0),
                            //                                      strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                            //                            .xAxisPOI(chartData: data,
                            //                                      markerName: "Worst",
                            //                                      markerValue: 2,
                            //                                      dataPointCount: data.dataSets.dataPoints.count,
                            //                                      lineColour: .red)
                            //                            .averageLine(chartData: data,
                            //                                         strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                            //                            .xAxisGrid(chartData: data)
                            .yAxisGrid(chartData: data)
                            //                            .xAxisLabels(chartData: data)
                            .yAxisLabels(chartData: data, colourIndicator: .custom(colour: ColourStyle.init(colour: .white), size: 12))
                            //                            .extraYAxisLabels(chartData: data, colourIndicator: .style(size: 12))
                            .infoBox(chartData: data)
                            .headerBox(chartData: data)
                            //                            .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                            .id(data.id)
                            .frame(minWidth: 150, maxWidth: 900, minHeight: 400, idealHeight: 450, maxHeight: 450, alignment: .center)
                            .padding([.horizontal])
                        
                        //                            .navigationTitle("Week of Data")
                        //                        LineView(data: demoData, title: "Glucose (mg/dL)", style: chartStyle)
                        //                            .padding(30)
                    }
                    
                }
                .frame(maxWidth: geometry.size.width)
                .frame(height: geometry.size.height + 40)
                .frame(alignment: .center)
            }
        }.frame(width: 380, height: 450)
    }
//    private var extraLineData: [ExtraLineDataPoint] {
//        [ExtraLineDataPoint(value: 8000),
//         ExtraLineDataPoint(value: 10000),
//         ExtraLineDataPoint(value: 15000),
//         ExtraLineDataPoint(value: 9000)]
//    }
//    private var extraLineStyle: ExtraLineStyle {
//        ExtraLineStyle(lineColour: ColourStyle(colour: .blue),
//                       lineType: .line,
//                       yAxisTitle: "Another Axis")
//    }
//   static func getModelData() -> [Float]
//   {
//    var chartValues = [Float]()
//        do {
//            let model = try SugarCalculation()
//
//            var mlArr =  try MLMultiArray(shape: [1 , 12 ,  1], dataType: MLMultiArrayDataType.float32)
//            let prediction = try model.prediction(bidirectional_input: mlArr )
//            print(prediction.Identity , prediction.featureNames, prediction.featureValue(for: "abc"))
//            var arrOfInput = [SugarCalculationInput]()
//           let dummy =  [132, 125, 120, 120, 118, 111, 104 ,99,  94,  91,  89,  84, ]
//            for i in 0...dummy.count - 1{
//                mlArr[i] = NSNumber(floatLiteral: Double(Float32(dummy[i])))
//                arrOfInput.append(SugarCalculationInput(bidirectional_input: mlArr))
//            }
//            arrOfInput.append(SugarCalculationInput(bidirectional_input: mlArr))
//            let inpput = SugarCalculationInput(bidirectional_input: mlArr)
//
//             let outPut = try model.predictions(inputs: arrOfInput)
//            print(outPut)
//            let dn = outPut[0].Identity
//            print(outPut[0].Identity)
//            if let b = try? UnsafeBufferPointer<Float>(dn) {
//              chartValues = Array(b)
//              print(chartValues)
//            }
//            print(outPut[0].featureValue(for: "Identity"))
//           // return outPut[0].Identity.dou
//        } catch  {
//            print(error)
//        }
//
//
//      return chartValues
//    }
    
    static func getModelData() -> [Float]
    {
     var chartValues = [Float]()
         do {
             let model = try SugarCalculation2()
             
             var mlArr =  try MLMultiArray(shape: [1 , 12 ,  1], dataType: MLMultiArrayDataType.float32)
            let prediction = try model.prediction(bidirectional_1_input: mlArr )
             print(prediction.Identity , prediction.featureNames, prediction.featureValue(for: "abc"))
             var arrOfInput = [SugarCalculation2Input]()
            var dummy =  [207,211, 208, 203, 201, 204, 203, 194, 190, 184, 173, 170 ]
             for i in 0...dummy.count - 1{
                 mlArr[i] = NSNumber(floatLiteral: Double(Float32(dummy[i])))
                arrOfInput.append(SugarCalculation2Input(bidirectional_1_input: mlArr))
             }
            arrOfInput.append(SugarCalculation2Input(bidirectional_1_input: mlArr))
            let inpput = SugarCalculation2Input(bidirectional_1_input: mlArr)
             
              let outPut = try model.predictions(inputs: arrOfInput)
             print(outPut)
             let dn = outPut[0].Identity
             print(outPut[0].Identity)
             if let b = try? UnsafeBufferPointer<Float>(dn) {
               chartValues = Array(b)
               print(chartValues)
             }
             print(outPut[0].featureValue(for: "Identity"))
            // return outPut[0].Identity.dou
         } catch  {
             print(error)
         }
         
        
       return chartValues
     }
    
    
    
    static func weekOfData() -> LineChartData {
        getModelData()
      
        let data = LineDataSet(dataPoints: [
            LineChartDataPoint(value: Double(getModelData()[0]), xAxisLabel: "M", description: "6:00"   ),
            LineChartDataPoint(value: Double(getModelData()[1]), xAxisLabel: "T", description: "10:00"  ),
            LineChartDataPoint(value: Double(getModelData()[2]) ,xAxisLabel: "W", description: "12:00"),
            LineChartDataPoint(value: Double(getModelData()[3]), xAxisLabel: "T", description: "14:00" ),
            LineChartDataPoint(value: Double(getModelData()[4]), xAxisLabel: "F", description: "17:00"   ),
            LineChartDataPoint(value: Double(getModelData()[5]), xAxisLabel: "S", description: "19:00" ),
            LineChartDataPoint(value: Double(getModelData()[6]) , xAxisLabel: "S", description: "23:00"   ),
            LineChartDataPoint(value: Double(getModelData()[7]) , xAxisLabel: "S", description: "11:00"   )
        ],
        legendTitle: "",
        pointStyle: PointStyle(),
        style: LineStyle(lineColour: ColourStyle(colour: Colors.GradientUpperOrange), lineType: .curvedLine))
        
        let gridStyle = GridStyle(numberOfLines: 7,
                                  lineColour   : Color(.lightGray).opacity(0.5),
                                  lineWidth    : 1,
                                  dash         : [8],
                                  dashPhase    : 0)
        
        let chartStyle = LineChartStyle(infoBoxPlacement    : .infoBox(isStatic: false),
                                        infoBoxContentAlignment: .vertical,
                                        infoBoxBorderColour : Color.white,
                                        infoBoxBorderStyle  : StrokeStyle(lineWidth: 1),
                                        
                                        markerType          : .vertical(attachment: .line(dot: .style(DotStyle()))),
                                        
                                        xAxisGridStyle      : gridStyle,
                                        xAxisLabelPosition  : .bottom,
                                        xAxisLabelColour    : Color.white,
                                        xAxisLabelsFrom     : .dataPoint(rotation: .degrees(0)),
                                        xAxisTitle          : "xAxisTitle",
                                        
                                        yAxisGridStyle      : gridStyle,
                                        yAxisLabelPosition  : .leading,
                                        yAxisLabelColour    : Color.white,
                                        yAxisNumberOfLabels : 7,
                                        
                                        baseline            : .minimumWithMaximum(of: 40),
                                        topLine             : .maximum(of: 280),
                                        
                                        globalAnimation     : .easeOut(duration: 1))
        
        
        
        let chartData = LineChartData(dataSets: data,
                                      metadata : ChartMetadata(
                                        title: "125mg/dl",
                                        subtitle: "Now",
                                        titleFont: Font.title.bold(),
                                        titleColour: .white,
                                        subtitleFont: Font.body.bold(),
                                        subtitleColour: .white
                                      ),
                                      chartStyle: chartStyle)
        
        defer {
            chartData.touchedDataPointPublisher
                .map(\.value)
                .sink { value in
                    var dotStyle: DotStyle
                    if value < 10_000 {
                        dotStyle = DotStyle(fillColour: .red)
                    } else if value >= 10_000 && value <= 15_000 {
                        dotStyle = DotStyle(fillColour: .blue)
                    } else {
                        dotStyle = DotStyle(fillColour: .green)
                    }
                    withAnimation(.linear(duration: 0.5)) {
                        chartData.chartStyle.markerType = .vertical(attachment: .line(dot: .style(dotStyle)))
                    }
                }
                .store(in: &chartData.subscription)
        }
        
        return chartData
        
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
