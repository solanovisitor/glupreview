//
//  NfcReader.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 19/09/21.
//

import SwiftUI
import CoreNFC


class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate {

    @Published var scannedData: Data?

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
    }
    
    func scanTag() {
        let session = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
        session?.alertMessage = "Hold your iPhone near the Libre Sensor"
        session?.begin()
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        // 2
        if case let NFCTag.iso15693(tag) = tags.first! {
            session.connect(to: tags.first!) { (error: Error?) in
            
                    tag.readSingleBlock(requestFlags: [.highDataRate, .address], blockNumber:0) { (response:
                        Data, error: Error?) in
                        
                }
            }
        }
    }
}

struct ScanView: View {

    @State private var currentlyScaning: Bool = false
    @State private var tagFound: Bool = false
    @State private var tagSync: Bool = false
    @ObservedObject var reader = NFCReader()
    
    var body: some View {
        VStack {
            Text("Please scan")
            Button("Scan") {
                reader.scanTag()
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}

