////
////  NFCReader.swift
////  Advanced SwiftUI
////
////  Created by Navin Bagul on 27/10/21.
////
//
//import Foundation
//import CoreNFC
//
//class NFCReaderClass: NSObject, NFCNDEFReaderSessionDelegate {
//    private var session : NFCNDEFReaderSession?
//    func scan() {
//        // Create a reader session and pass self as delegate
//        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
//        session?.begin()
//    }
//
//    // MARK: delegate methods
//    // Implement the NDEF reader delegate protocol.
//
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        // Error handling
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        // Handle received messages
//    }
// 
//}
//class NFCReaderClass: NSObject, NFCTagReaderSessionDelegate {
//
//    // Error handling again
//    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) { }
//
//    // Additionally there's a function that's called when the session begins
//    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
//
//    // Note that an NFCTag array is passed into this function, not a [NFCNDEFMessage]
//    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
//        session.connect(to: tags.first!) { (error: Error?) in
//              if error != nil {
//                  session.invalidate(errorMessage: "Connection error. Please try again.")
//                  return
//              }
//
//              print("Connected to tag!")
//
//              switch nfcTag {
//              case .miFare(let discoveredTag):
//                  print("Got a MiFare tag!", discoveredTag.identifier, discoveredTag.mifareFamily)
//              case .feliCa(let discoveredTag):
//                  print("Got a FeliCa tag!", discoveredTag.currentSystemCode, discoveredTag.currentIDm)
//              case .iso15693(let discoveredTag):
//                  print("Got a ISO 15693 tag!", discoveredTag.icManufacturerCode, discoveredTag.icSerialNumber, discoveredTag.identifier)
//              case .iso7816(let discoveredTag):
//                  print("Got a ISO 7816 tag!", discoveredTag.initialSelectedAID, discoveredTag.identifier)
//              @unknown default:
//                  session.invalidate(errorMessage: "Unsupported tag!")
//              }
//    }
//}
//
//}
