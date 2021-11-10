//
//  ButtonView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 30/09/21.
//

import SwiftUI
import CoreNFC
import UIKit

struct ScanButton: View {
    @State var data = ""
    @State var buttonTitle = ""
    var gradient1: [Color] = [
        Color.init(red: 101/255, green: 134/255, blue: 1),
        Color.init(red: 1, green: 64/255, blue: 80/255),
        Color.init(red: 109/255, green: 1, blue: 185/255),
        Color.init(red: 39/255, green: 232/255, blue: 1),
    ]

    @State private var angle: Double = 0

    var body: some View {
            VStack {
                VStack(alignment: .center, spacing: 16) {
                    //Button
                    GeometryReader { geometry in
                    ZStack {
                        AngularGradient(gradient: Gradient(colors: gradient1), center: .center, angle: .degrees(angle))
                            .blendMode(.overlay)
                            .blur(radius: 8.0)
                            .mask(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(maxWidth: geometry.size.width - 15)
                                    .frame(height: 50)
                                    .blur(radius: 8)
                            )
                            .onAppear {
                                withAnimation(.linear(duration: 7)) {
                                    self.angle += 350
                                }
                            }
                        RoundedRectangle(cornerRadius: 16)
                        .fill(Color(#colorLiteral(red: 0.10078595578670502, green: 0.06947916746139526, blue: 0.24166665971279144, alpha: 0.8999999761581421)))

                        RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), lineWidth: 1)
                        .blendMode(.softLight)
                        
                        //Start
                        GradientText(text: buttonTitle)
                            .font(.headline)
                            .frame(maxWidth: geometry.size.width)
                            .frame(height: 50)
                            .background(
                                Color("tertiaryBackground")
                                    .opacity(0.9)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16.0)
                                    .stroke(Color.white, lineWidth: 1.0)
                                    .blendMode(.normal)
                                    .opacity(0.7)
                            )
                            .cornerRadius(16.0)
                        nfcButton(data: self.$data)
                    }
                    
                    
                    }
                    .frame(width: 319, height: 50)
            }
        }
    }
}

struct ScanButton_Previews: PreviewProvider {
    static var previews: some View {
        ScanButton(buttonTitle: "Scan!")
    }
}

struct nfcButton: UIViewRepresentable {
    @Binding var data: String

    func makeUIView(context: UIViewRepresentableContext<nfcButton>) -> UIButton {
        let button = UIButton()
        button.addTarget(context.coordinator, action: #selector(context.coordinator.scan(_:)), for: .touchUpInside)

        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> nfcButton.Coordinator {
        return Coordinator(data: $data)
    }
    
    class Coordinator: NSObject, NFCTagReaderSessionDelegate , NFCNDEFReaderSessionDelegate {
        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            print(error)
        }
        
        func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
            print(messages)
        }
        
        var session: NFCTagReaderSession?
        @Binding var data: String
        @Published var scannedData: Data?
        
        init(data: Binding<String>) {
            _data = data
        }
        
        @objc func scan(_ sender: Any) {
            // Look for ISO 14443 and ISO 15693 tags
            let session = NFCTagReaderSession(pollingOption: .iso15693, delegate: self, queue: .main)
            session?.begin()
        }
        
        
        func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
            // Do nothing
        }
        
        func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
            // Do nothing
        }
        
        func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
            
            if tags.count > 1 {
                print("More than 1 sensor was found. Please present only 1 sensor.")
                session.invalidate(errorMessage: "More than 1 sensor was found. Please present only 1 sensor.")
                return
            }

            guard let firstTag = tags.first else {
                print("Unable to get sensor")
                session.invalidate(errorMessage: "Unable to get first sensor")
                return
            }

            print("Sensor found!", firstTag)
            
            session.connect(to: tags.first!) { (error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }

                print("Connected to sensor!")
                
                switch firstTag {
                case .iso15693(let tag):
                    // Read one block of data
                    tag.readSingleBlock(requestFlags: .highDataRate, blockNumber: 1, resultHandler: { result in
                        switch result {
                        case .success(let str):
                            self.data = String(decoding: str, as: UTF8.self)
                            var dummy =  [207,211, 208, 203, 201, 204, 203, 194, 190, 184, 173, 170 ]
                        case .failure(let error):
                            print(error)
                        }
                        })
                case .feliCa(_): session.invalidate(errorMessage: "Unsupported tag!")
                case .iso7816(_): session.invalidate(errorMessage: "Unsupported tag!")
                case .miFare(_): session.invalidate(errorMessage: "Unsupported tag!")
                @unknown default: session.invalidate(errorMessage: "Unsupported tag!")
                }
                }
            }
        }
    }



