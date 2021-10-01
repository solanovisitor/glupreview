//
//  ScanView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 30/09/21.
//

import SwiftUI
import CoreNFC
import UIKit

struct ScanView: View {
    @State var data = ""
    
    var body: some View {
        VStack {
            Text(data)
            nfcButton(data: self.$data)
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}

struct nfcButton: UIViewRepresentable {
    @Binding var data: String
    func makeUIView(context: UIViewRepresentableContext<nfcButton>) -> UIButton {
        let button = UIButton()
        button.setTitle("Ready to scan!", for: .normal)
        button.backgroundColor = UIColor.purple
        button.addTarget(context.coordinator, action: #selector(context.coordinator.scan(_:)), for: .touchUpInside)

        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> nfcButton.Coordinator {
        return Coordinator(data: $data)
    }
    
    class Coordinator: NSObject, NFCTagReaderSessionDelegate {
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
}


