//
//  NfcReader.swift
//  Advanced SwiftUI
//
//  Created by Solano Todeschini on 19/09/21.
//
import SwiftUI
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

