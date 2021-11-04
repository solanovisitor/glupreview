//
//  NFCReader.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 11/10/2021.
//
//
import SwiftUI
import CoreNFC


class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate , NFCNDEFReaderSessionDelegate{
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(session)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
       print(session, messages)
    }
    
   
     
    @Published var scannedData: Data?
    var session: NFCReaderSession?
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Session", session.connectedTag )
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Session", session.connectedTag , error)
    }
    
    func scanTag() {
         session = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
        session?.alertMessage = "Hold your iPhone near the Libre Sensor"
        session?.begin()
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        // 2
        print(session)
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

        print("Got a tag!", firstTag)
        session.connect(to: firstTag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            print("Connected to tag!")

           // var importPromise: Promise<TransitTag>?

            switch firstTag {
            case .miFare(let discoveredTag):
                print("Got a MiFare tag!", discoveredTag.identifier, discoveredTag.mifareFamily)
               // importPromise = ClipperTag().importTag(discoveredTag)
            case .feliCa(let discoveredTag):
                print("Got a FeliCa tag!", discoveredTag.currentSystemCode, discoveredTag.currentIDm)
            case .iso15693(let discoveredTag):
                print("Got a ISO 15693 tag!", discoveredTag.icManufacturerCode, discoveredTag.icSerialNumber, discoveredTag.identifier)
                print("- Is available: \(discoveredTag.isAvailable)")
                           print("- Type: \(discoveredTag.type)")
                           print("- IC Manufacturer Code: \(discoveredTag.icManufacturerCode)")
                           print("- IC Serial Number: \(discoveredTag.icSerialNumber)")
                           print("- Identifier: \(discoveredTag.identifier)")
                let stringValue = String(data: discoveredTag.identifier, encoding: .utf8)
                let stringVal = String(data: discoveredTag.icSerialNumber, encoding: .utf8)
                print(stringVal, stringValue)
                
                session.connect(to: firstTag) { error in
                    if error != nil {
                        print(error!.localizedDescription)
                        session.invalidate(errorMessage: "Application failure")
                        return
                    }
                    discoveredTag.readMultipleBlocks(requestFlags: [.address, .highDataRate], blockRange: NSMakeRange(0, 8)) { data , error in
                        if error != nil {
                            print(error!.localizedDescription)
                            session.invalidate(errorMessage: "Application failure")
                            return
                        }
                        
                        
                        DispatchQueue.main.async {
                            for i in data {
                                print(String(data: i, encoding: .utf32))
                            }
                          
                        }
                    }

//                    discoveredTag.readSingleBlock(requestFlags: [.commandSpecificBit8, .address , .dualSubCarriers, .option , .highDataRate , .protocolExtension], blockNumber: 255) { (data, error) in
//                        if error != nil {
//                            print(error!.localizedDescription)
//                            session.invalidate(errorMessage: "Application failure")
//                            return
//                        }
//                        
//                        
//                        DispatchQueue.main.async {
//                           print(String(data: data, encoding: .utf8))
//                        }
//                        
//                        session.invalidate()
//                    }
                }

            case .iso7816(let discoveredTag):
                print("Got a ISO 7816 tag!", discoveredTag.initialSelectedAID, discoveredTag.identifier)
            @unknown default:
                session.invalidate(errorMessage: "TransitPal doesn't support this kind of tag!")
            }

//            importPromise?.done { tag in
//                print("Got tag!", tag)
//                self.processedTag = tag
//                session.invalidate()
//            }.catch { err in
//                session.invalidate(errorMessage: err.localizedDescription)
//            }
        }
//        if case let NFCTag.iso15693(tag) = tags.first! {
//            session.connect(to: tags.first!) { (error: Error?) in
//
//                    tag.readSingleBlock(requestFlags: [.highDataRate, .address], blockNumber:0) { (response:
//                        Data, error: Error?) in
//                        print(response)
//                }
//            }
//        }
    }
}
