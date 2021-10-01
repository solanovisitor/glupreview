//
//  ScanView.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 30/09/21.
//

import SwiftUI
import CoreNFC

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
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Ready to scan!", for: .normal)
        button.backgroundColor = UIColor.purple
        button.addTarget(context, action: #selector(context.coordinator.scan(_:)), for: .touchUpOutside)
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
        
        init(data: Binding<String>) {
            _data = data
        }
        
        @objc func scan(_ sender: Any) {
            // Look for ISO 14443 and ISO 15693 tags
            let session = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
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
                print("More than 1 tag was found. Please present only 1 tag.")
                session.invalidate(errorMessage: "More than 1 tag was found. Please present only 1 tag.")
                return
            }

            guard let firstTag = tags.first else {
                print("Unable to get first tag")
                session.invalidate(errorMessage: "Unable to get first tag")
                return
            }

            print("Got a Tag!", firstTag)
            
            session.connect(to: tags.first!) { (error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }

                print("Connected to tag!")
                
                switch firstTag {
                case .iso15693(let tag):
                    // Read one block of data
                    tag.readSingleBlock(requestFlags: .highDataRate, blockNumber: 1, resultHandler: { result in
                        print(result)
                    })
                default:
                    session.invalidate(errorMessage: "Unsupported NFC tag.")
                }
            }
        }
    }
}
}
