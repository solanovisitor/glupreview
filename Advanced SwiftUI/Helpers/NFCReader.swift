//
//  NFCReader.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 11/10/2021.
//
//
import SwiftUI
import CoreNFC
import Combine
import PromiseKit
import AVFoundation
import Foundation





struct NFCCommand {
    let code: Int
    var parameters: Data = Data()
    var description: String = ""
}

enum NFCError: LocalizedError {
    case commandNotSupported
    case customCommandError
    case read
    case readBlocks
    case write
    
    var errorDescription: String? {
        switch self {
        case .commandNotSupported: return "command not supported"
        case .customCommandError:  return "custom command error"
        case .read:                return "read error"
        case .readBlocks:          return "reading blocks error"
        case .write:               return "write error"
        }
    }
}


extension Sensor {
    
    var backdoor: Data {
        switch self.type {
        case .libre1:    return Data([0xc2, 0xad, 0x75, 0x21])
        case .libreProH: return Data([0xc2, 0xad, 0x00, 0x90])
        default:         return Data([0xde, 0xad, 0xbe, 0xef])
        }
    }
    
    var activationCommand: NFCCommand {
        switch self.type {
        case .libre1:
            return NFCCommand(code: 0xA0, parameters: backdoor, description: "activate")
        case .libreProH:
            return NFCCommand(code: 0xA0, parameters: backdoor + "4A454D573136382D5430323638365F23".bytes, description: "activate")
        case .libre2:
            return nfcCommand(.activate)
        default:
            return NFCCommand(code: 0x00)
        }
    }
    
    var universalCommand: NFCCommand    { NFCCommand(code: 0xA1, description: "A1 universal prefix") }
    var getPatchInfoCommand: NFCCommand { NFCCommand(code: 0xA1, description: "get patch info") }
    
    // Libre 1
    var lockCommand: NFCCommand         { NFCCommand(code: 0xA2, parameters: backdoor, description: "lock") }
    var readRawCommand: NFCCommand      { NFCCommand(code: 0xA3, parameters: backdoor, description: "read raw") }
    var unlockCommand: NFCCommand       { NFCCommand(code: 0xA4, parameters: backdoor, description: "unlock") }
    
    // Libre 2 / Pro
    // SEE: custom commands C0-C4 in TI RF430FRL15xH Firmware User's Guide
    var readBlockCommand: NFCCommand    { NFCCommand(code: 0xB0, description: "B0 read block") }
    var readBlocksCommand: NFCCommand   { NFCCommand(code: 0xB3, description: "B3 read blocks") }
    
    /// replies with error 0x12 (.contentCannotBeChanged)
    var writeBlockCommand: NFCCommand   { NFCCommand(code: 0xB1, description: "B1 write block") }
    
    /// replies with errors 0x12 (.contentCannotBeChanged) or 0x0f (.unknown)
    /// writing three blocks is not supported because it exceeds the 32-byte input buffer
    var writeBlocksCommand: NFCCommand  { NFCCommand(code: 0xB4, description: "B4 write blocks") }
    
    /// Usual 1252 blocks limit:
    /// block 04e3 => error 0x11 (.blockAlreadyLocked)
    /// block 04e4 => error 0x10 (.blockNotAvailable)
    var lockBlockCommand: NFCCommand   { NFCCommand(code: 0xB2, description: "B2 lock block") }
    
    
    enum Subcommand: UInt8, CustomStringConvertible {
        case unlock          = 0x1a    // lets read FRAM in clear and dump further blocks with B0/B3
        case activate        = 0x1b
        case enableStreaming = 0x1e
        case getSessionInfo  = 0x1f    // GEN_SECURITY_CMD_GET_SESSION_INFO
        case unknown0x10     = 0x10    // returns the number of parameters + 3
        case unknown0x1c     = 0x1c
        case unknown0x1d     = 0x1d    // disables Bluetooth
        // Gen2
        case readChallenge   = 0x20    // returns 25 bytes
        case readBlocks      = 0x21
        case readAttribute   = 0x22    // returns 6 bytes ([0]: sensor state)
        
        var description: String {
            switch self {
            case .unlock:          return "unlock"
            case .activate:        return "activate"
            case .enableStreaming: return "enable BLE streaming"
            case .getSessionInfo:  return "get session info"
            case .readChallenge:   return "read security challenge"
            case .readBlocks:      return "read FRAM blocks"
            case .readAttribute:   return "read patch attribute"
            default:               return "[unknown: 0x\(rawValue.hex)]"
            }
        }
    }
    
    
    /// The customRequestParameters for 0xA1 are built by appending
    /// code + params (b) + usefulFunction(uid, code, secret (y))
    func nfcCommand(_ code: Subcommand, parameters: Data = Data()) -> NFCCommand {
        
        var parameters = Data([code.rawValue]) + parameters
        
        var b: [UInt8] = []
        var y: UInt16 = 0x1b6a
        
        if code == .enableStreaming {
            
            // Enables Bluetooth on Libre 2. Returns peripheral MAC address to connect to.
            // streamingUnlockCode could be any 32 bit value. The streamingUnlockCode and
            // sensor Uid / patchInfo will have also to be provided to the login function
            // when connecting to peripheral.
            
            b = [
                UInt8(streamingUnlockCode & 0xFF),
                UInt8((streamingUnlockCode >> 8) & 0xFF),
                UInt8((streamingUnlockCode >> 16) & 0xFF),
                UInt8((streamingUnlockCode >> 24) & 0xFF)
            ]
            y = UInt16(patchInfo[4...5]) ^ UInt16(b[1], b[0])
        }
        
        if b.count > 0 {
            parameters += b
        }
        
        if code.rawValue < 0x20 {
            let d = Libre2.usefulFunction(id: uid, x: UInt16(code.rawValue), y: y)
            parameters += d
        }
        
        return NFCCommand(code: 0xA1, parameters: parameters, description: code.description)
    }
}

var sensor: Sensor!


class NFCReader: NSObject, ObservableObject, NFCTagReaderSessionDelegate , NFCNDEFReaderSessionDelegate{
    var connectedTag: NFCISO15693Tag?
    var systemInfo: NFCISO15693SystemInfo!
   // var sensor: Sensor!
    
    var securityChallenge: Data = Data()
    var authContext: Int = 0
    var sessionInfo: Data = Data()
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(session)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
       print(session, messages)
    }
    
    
    var taskRequest: TaskRequest? {
        didSet {
            guard taskRequest != nil else { return }
           scanTag()
        }
    }
     
    @Published var scannedData: Data?
     var session: NFCReaderSession?
    var sessionA: NFCNDEFReaderSession?
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("Session", session.connectedTag )
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Session", session.connectedTag , error)
    }
    
    func scanTag() {
        session = NFCTagReaderSession(pollingOption: [.iso15693], delegate: self , queue: .main)
        session?.alertMessage = "Hold your iPhone near the Libre Sensor"
        session?.begin()
        
        
        
       // ChartView(tempData: [ 194, 190, 184, 173, 170,207,211, 208, 203, 201, 204, 203])
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
        session.connect(to: firstTag) { [self] (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

            print("Connected to tag!")

            var importPromise: Promise<TransitTag>?

            switch firstTag {
            case .miFare(let tag):
                print("Got a MiFare tag!", tag.identifier, tag.mifareFamily)
               // importPromise = ClipperTag().importTag(discoveredTag)
            case .feliCa(let tag):
                print("Got a FeliCa tag!", tag.currentSystemCode, tag.currentIDm)
            case .iso15693(let tag):
                print("Got a ISO 15693 tag!", tag.icManufacturerCode, tag.icSerialNumber, tag.identifier)
                print("- Is available: \(tag.isAvailable)")
                           print("- Type: \(tag.type)")
                           print("- IC Manufacturer Code: \(tag.icManufacturerCode)")
                           print("- IC Serial Number: \(tag.icSerialNumber)")
                           print("- Identifier: \(tag.identifier)")
                
                let stringValue = String(data: tag.identifier, encoding: .utf8)
                let stringVal = String(data: tag.icSerialNumber, encoding: .utf8)
                print(stringVal, stringValue)
                
                
//                    sessionA = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
//                    
//                    sessionA?.alertMessage = "Hold your iPhone near the item to learn more about it."
                   
                
                
                session.connect(to: firstTag) { error in
                    if error != nil {
                        print(error!.localizedDescription)
                        session.invalidate(errorMessage: "Application failure")
                        return
                    }
                    let tagUIDData = tag.identifier
                      var byteData: [UInt8] = []
                      tagUIDData.withUnsafeBytes { byteData.append(contentsOf: $0) }
                      var uidString = ""
                      for byte in byteData {
                      let decimalNumber = String(byte, radix: 16)
                      if (Int(decimalNumber) ?? 0) < 16 {
                      uidString.append("0\(decimalNumber)")
                      } else {
                      uidString.append(decimalNumber)
                      }
                      }
                    
                    Task {
                        
                        do {
                            try await session.connect(to: firstTag)
                            connectedTag = tag
                        } catch {
                            print("NFC: \(error.localizedDescription)")
                            session.invalidate(errorMessage: "Connection failure: \(error.localizedDescription)")
                            return
                        }
                        
                        let retries = 5
                        var requestedRetry = 0
                        var failedToScan = false
                        repeat {
                            failedToScan = false
                            if requestedRetry > 0 {
                                AudioServicesPlaySystemSound(1520)    // "pop" vibration
                                print("NFC: retry # \(requestedRetry)...")
                                // await Task.sleep(250_000_000) not needed: too long
                            }
                            
                            // Libre 3 workaround: calling A1 before tag.sytemInfo makes them work
                            // The first reading prepends further 7 0xA5 dummy bytes
                            
                            do {
                               
                                print(Data() , 0xA1, tag)
                                print(Data(try await tag.customCommand(requestFlags: [.highDataRate], customCommandCode: 0xA1, customRequestParameters: Data())))
                                sensor.patchInfo = Data(try await tag.customCommand(requestFlags: [.highDataRate], customCommandCode: 0xA1, customRequestParameters: Data(bytes: [UInt8(0x0D), UInt8(0x01)])))
                                print(sensor.patchInfo)
                            } catch {
                                failedToScan = true
                            }
                            
                            do {
                                systemInfo = try await tag.systemInfo(requestFlags: .highDataRate)
                                AudioServicesPlaySystemSound(1520)    // initial "pop" vibration
                            } catch {
                                print("NFC: error while getting system info: \(error.localizedDescription)")
                                if requestedRetry > retries {
                                    session.invalidate(errorMessage: "Error while getting system info: \(error.localizedDescription)")
                                    return
                                }
                                failedToScan = true
                                requestedRetry += 1
                            }
                            
                            do {
                                print(tag)
                                
                                sensor.patchInfo = Data(try await tag.customCommand(requestFlags: .highDataRate, customCommandCode: 0xA1, customRequestParameters: Data(bytes: [UInt8(0x0D), UInt8(0x01)])))
                            } catch {
                                print("NFC: error while getting patch info: \(error.localizedDescription)")
                                if requestedRetry > retries && systemInfo != nil {
                                    requestedRetry = 0 // break repeat
                                } else {
                                    if !failedToScan {
                                        failedToScan = true
                                        requestedRetry += 1
                                    }
                                }
                            }
                            
                        } while failedToScan && requestedRetry > 0
                        
                        
                        // https://www.st.com/en/embedded-software/stsw-st25ios001.html#get-software
                        
                        let uid = tag.identifier.hex
                        print("NFC: IC identifier: \(uid)")
                        
                        var manufacturer = tag.icManufacturerCode.hex
                        if manufacturer == "07" {
                            manufacturer.append(" (Texas Instruments)")
                        } else if manufacturer == "7a" {
                            manufacturer.append(" (Abbott Diabetes Care)")
                            sensor.type = .libre3
                            sensor.securityGeneration = 3 // TODO: test
                        }
                        print("NFC: IC manufacturer code: 0x\(manufacturer)")
                        print("NFC: IC serial number: \(tag.icSerialNumber.hex)")
                        
                        var firmware = "RF430"
                        switch tag.identifier[2] {
                        case 0xA0: firmware += "TAL152H Libre 1 A0 "
                        case 0xA4: firmware += "TAL160H Libre 2 A4 "
                        case 0x00: firmware = "unknown Libre 3 "
                        default:   firmware += " unknown "
                        }
                        print("NFC: \(firmware)firmware")
                        
                        print(String(format: "NFC: IC reference: 0x%X", systemInfo.icReference))
                        if systemInfo.applicationFamilyIdentifier != -1 {
                            print(String(format: "NFC: application family id (AFI): %d", systemInfo.applicationFamilyIdentifier))
                        }
                        if systemInfo.dataStorageFormatIdentifier != -1 {
                            print(String(format: "NFC: data storage format id: %d", systemInfo.dataStorageFormatIdentifier))
                        }
                        
                        print(String(format: "NFC: memory size: %d blocks", systemInfo.totalBlocks))
                        print(String(format: "NFC: block size: %d", systemInfo.blockSize))
                        
                        sensor.uid = Data(tag.identifier.reversed())
                        print("NFC: sensor uid: \(sensor.uid.hex)")
                        
                        if sensor.patchInfo.count > 0 {
                            print("NFC: patch info: \(sensor.patchInfo.hex)")
                            print("NFC: sensor type: \(sensor.type.rawValue)\(sensor.patchInfo.hex.hasPrefix("a2") ? " (new 'A2' kind)" : "")")
                            
                             
                        }
                        
                        print("NFC: sensor serial number: \(sensor.serial)")
                        
                        if taskRequest != .none {
                            
                            /// Libre 1 memory layout:
                            /// config: 0x1A00, 64    (sensor UID and calibration info)
                            /// sram:   0x1C00, 512
                            /// rom:    0x4400 - 0x5FFF
                            /// fram lock table: 0xF840, 32
                            /// fram:   0xF860, 1952
                            
                            if taskRequest == .dump {
                                
                                do {
                                    var (address, data) = try await readRaw(0x1A00, 64)
                                    print(data.hexDump(header: "Config RAM (patch UID at 0x1A08):", address: address))
                                    (address, data) = try await readRaw(0x1C00, 512)
                                    print(data.hexDump(header: "SRAM:", address: address))
                                    (address, data) = try await readRaw(0xFFAC, 36)
                                    print(data.hexDump(header: "Patch table for A0-A4 E0-E2 commands:", address: address))
                                    (address, data) = try await readRaw(0xF860, 43 * 8)
                                    print(data.hexDump(header: "FRAM:", address: address))
                                } catch {}
                                
                                do {
                                    let (start, data) = try await read(fromBlock: 0, count: 43)
                                    print(data.hexDump(header: "ISO 15693 FRAM blocks:", startingBlock: start))
                                    sensor.fram = Data(data)
                                    if sensor.encryptedFram.count > 0 && sensor.fram.count >= 344 {
                                        print("\(sensor.fram.hexDump(header: "Decrypted FRAM:", startingBlock: 0))")
                                    }
                                } catch {
                                }
                                
                                /// count is limited to 89 with an encrypted sensor (header as first 3 blocks);
                                /// after sending the A1 1A subcommand the FRAM is decrypted in-place
                                /// and mirrored in the last 43 blocks of 89 but the max count becomes 1252
                                var count = sensor.encryptedFram.count > 0 ? 89 : 1252
                                if sensor.securityGeneration > 1 { count = 43 }
                                
                                let command = sensor.securityGeneration > 1 ? "A1 21" : "B0/B3"
                                
                                do {
                                    defer {
                                        taskRequest = .none
                                        session.invalidate()
                                    }
                                    
                                    let (start, data) = try await readBlocks(from: 0, count: count)
                                    
                                     
                                    
                                    let blocks = data.count / 8
                                    
                                 
                                    
                                    // await main actor
//                                    if await main.settings.debugLevel > 0 {
//                                        let bytes = min(89 * 8 + 34 + 10, data.count)
//                                        var offset = 0
//                                        var i = offset + 2
//                                        while offset < bytes - 3 && i < bytes - 1 {
//                                            if UInt16(data[offset ... offset + 1]) == data[offset + 2 ... i + 1].crc16 {
//                                                print("CRC matches for \(i - offset + 2) bytes at #\((offset / 8).hex) [\(offset + 2)...\(i + 1)] \(data[offset ... offset + 1].hex) = \(data[offset + 2 ... i + 1].crc16.hex)\n\(data[offset ... i + 1].hexDump(header: "\(libre2DumpMap[offset]?.1 ?? "[???]"):", address: 0))")
//                                                offset = i + 2
//                                                i = offset
//                                            }
//                                            i += 2
//                                        }
//                                    }
                                    
                                } catch {
                                    print("NFC: 'read blocks \(command)' command error: \(error.localizedDescription) ")
                                }
                                return
                            }
                            
                            if sensor.securityGeneration > 1 {
                                var commands: [NFCCommand] = [sensor.nfcCommand(.readAttribute),
                                                              sensor.nfcCommand(.readChallenge)
                                ]
                                
                              
           
                            }
                             
                        }
                        
                        var blocks = 43
                        if taskRequest == .readFRAM {
                            if sensor.type == .libre1 {
                                blocks = 244
                            }
                        }
                        
                        do {
                            
           
                            
                            let (start, data) = try await sensor.securityGeneration < 2 ?
                            read(fromBlock: 0, count: blocks) : readBlocks(from: 0, count: blocks)
                            print(sensor.fram = Data(data))
                            let lastReadingDate = Date()
                            
                            // "Publishing changes from background threads is not allowed"
                            DispatchQueue.main.async {
                              //  self.main.app.lastReadingDate = lastReadingDate
                                print("-----Date", lastReadingDate)
                            }
                            sensor.lastReadingDate = lastReadingDate
                            
                             
                            session.invalidate()
                            
                            print(data.hexDump(header: "NFC: did read \(data.count / 8) FRAM blocks:", startingBlock: start))
                            
       
                            sensor.fram = Data(data)
                            
                        } catch {
                            
                            session.invalidate(errorMessage: "\(error.localizedDescription)")
                        }
                        
                        let tagUIDData = tag.identifier
                        var byteData: [UInt8] = []
                        tagUIDData.withUnsafeBytes { byteData.append(contentsOf: $0) }
                        var uidString = ""
                        for byte in byteData {
                            let decimalNumber = String(byte, radix: 16)
                            if (Int(decimalNumber) ?? 0) < 16 {
                                uidString.append("0\(decimalNumber)")
                            } else {
                                uidString.append(decimalNumber)
                            }
                        }
                        print("Previous History",sensor.history)
                        print("Current Glucose Data",sensor.currentGlucose ,sensor.$currentGlucose)
                        if sensor.currentGlucose > 0{
                            await ChartView(data: ChartView.weekOfData(), tempData: [sensor.currentGlucose])
                        }
                        
                    }
                    
                      debugPrint("\(byteData) converted to Tag UID: \(uidString)")
                      
//                    discoveredTag.readMultipleBlocks(requestFlags: [.address, .highDataRate], blockRange: NSMakeRange(0, 8)) { data , error in
//                        if error != nil {
//                            print(error!.localizedDescription)
//                            session.invalidate(errorMessage: "Application failure")
//                            return
//                        }
//
//
//                        DispatchQueue.main.async {
//                            for i in data {
//                                print(String(data: i, encoding: .utf32))
//                            }
//
//                        }
//                    }
                
                    tag.readSingleBlock(requestFlags: [.commandSpecificBit8, .address , .dualSubCarriers, .option , .highDataRate , .protocolExtension], blockNumber: 255) { (data, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                          //  session.invalidate(errorMessage: "Application failure")
                            return
                        }
                        
                        
                        DispatchQueue.main.async {
                           print(String(data: data, encoding: .utf8))
                        }
                        
                        
                        session.invalidate()
                    }
                }

            case .iso7816(let discoveredTag):
                print("Got a ISO 7816 tag!", discoveredTag.initialSelectedAID, discoveredTag.identifier)
            @unknown default:
                session.invalidate(errorMessage: "TransitPal doesn't support this kind of tag!")
            }

            importPromise?.done { tag in
                print("Got tag!", tag)
                //self.processedTag = tag
                
                session.invalidate()
            }.catch { err in
                session.invalidate(errorMessage: err.localizedDescription)
            }
        }
        if case let NFCTag.iso15693(tag) = tags.first! {
            session.connect(to: tags.first!) { (error: Error?) in

                    tag.readSingleBlock(requestFlags: [.highDataRate, .address], blockNumber:0) { (response:
                        Data, error: Error?) in
                        print("NFC A",response)
                        print("NFC A", String(decoding: response, as: UTF8.self))
                        print("NFC A",String(bytes: response, encoding: .utf8) as Any )
                        print("NFC A",response)
                        
                        if let string = String(bytes: response, encoding: String.Encoding.utf8) {
                            print(string)
                        } else {
                            print("not a valid UTF-8 sequence")
                        }
                }
            }
        }
    }
    @discardableResult
    func send(_ cmd: NFCCommand) async throws -> Data {
        var data = Data()
        do {
            print("NFC: sending \(sensor.type) '\(cmd.code.hex) \(cmd.parameters.hex)' custom command\(cmd.description == "" ? "" : " (\(cmd.description))")")
            let output = try await connectedTag?.customCommand(requestFlags: .highDataRate, customCommandCode: cmd.code, customRequestParameters: cmd.parameters)
            data = Data(output!)
        } catch {
            print("NFC: \(sensor.type) '\(cmd.description) \(cmd.code.hex) \(cmd.parameters.hex)' custom command error: \(error.localizedDescription)  ")
            throw error
        }
        return data
    }
    
    
    func read(fromBlock start: Int, count blocks: Int, requesting: Int = 3, retries: Int = 5) async throws -> (Int, Data) {
        
        var buffer = Data()
        
        var remaining = blocks
        var requested = requesting
        var retry = 0
        
        while remaining > 0 && retry <= retries {
            
            let blockToRead = start + buffer.count / 8
            
            do {
                let dataArray = try await connectedTag?.readMultipleBlocks(requestFlags: .highDataRate, blockRange: NSRange(blockToRead ... blockToRead + requested - 1))
                
                for data in dataArray! {
                    buffer += data
                }
                
                remaining -= requested
                
                if remaining != 0 && remaining < requested {
                    requested = remaining
                }
                
            } catch {
                
                print("NFC: error while reading multiple blocks   ")
                
                retry += 1
                if retry <= retries {
                    AudioServicesPlaySystemSound(1520)    // "pop" vibration
                    print("NFC: retry # \(retry)...")
                    await Task.sleep(250_000_000)
                    
                } else {
                    if sensor.securityGeneration < 2 || taskRequest == .none {
                        session?.invalidate(errorMessage: "Error while reading multiple blocks: \(error.localizedDescription.localizedLowercase)")
                    }
                    throw NFCError.read
                }
            }
        }
        
        return (start, buffer)
    }
    
    
    func readBlocks(from start: Int, count blocks: Int, requesting: Int = 3) async throws -> (Int, Data) {
        
        if sensor.securityGeneration < 1 {
            print("readBlocks() B3 command not supported by \(sensor.type)")
            throw NFCError.commandNotSupported
        }
        
        var buffer = Data()
        
        var remaining = blocks
        var requested = requesting
        
        while remaining > 0 {
            
            let blockToRead = start + buffer.count / 8
            
            var readCommand = NFCCommand(code: 0xB3, parameters: Data([UInt8(blockToRead & 0xFF), UInt8(blockToRead >> 8), UInt8(requested - 1)]))
            if requested == 1 {
                readCommand = NFCCommand(code: 0xB0, parameters: Data([UInt8(blockToRead & 0xFF), UInt8(blockToRead >> 8)]))
            }
            
            // FIXME: the Libre 3 replies to 'A1 21' with the error code C1
            
//            if sensor.securityGeneration > 1 {
//                if blockToRead <= 255 {
//                    readCommand = sensor.nfcCommand(.readBlocks, parameters: Data([UInt8(blockToRead), UInt8(requested - 1)]))
//                }
//            }
            
            if buffer.count == 0 { print("NFC: sending '\(readCommand.code.hex) \(readCommand.parameters.hex)' custom command (\(sensor.type) read blocks)") }
            
            do {
                let output = try await connectedTag?.customCommand(requestFlags: .highDataRate, customCommandCode: readCommand.code, customRequestParameters: readCommand.parameters)
                let data = Data(output!)
                
                if sensor.securityGeneration < 2 {
                    buffer += data
                } else {
                    print("'\(readCommand.code.hex) \(readCommand.parameters.hex) \(readCommand.description)' command output (\(data.count) bytes): 0x\(data.hex)")
                    buffer += data.suffix(data.count - 8)    // skip leading 0xA5 dummy bytes
                }
                remaining -= requested
                
                if remaining != 0 && remaining < requested {
                    requested = remaining
                }
                
            } catch {
                
                print(buffer.hexDump(header: "\(sensor.securityGeneration > 1 ? "`A1 21`" : "B0/B3") command output (\(buffer.count/8) blocks):", startingBlock: start))
                
                if requested == 1 {
                    print("NFC: error while reading block  ")
                } else {
                    print("NFC: error while reading multiple blocks #\(blockToRead.hex) - #\((blockToRead + requested - 1).hex)  \(error.localizedDescription)  ")
                }
                throw NFCError.readBlocks
            }
        }
        
        return (start, buffer)
    }
    
    
    // Libre 1 only
    
    func readRaw(_ address: Int, _ bytes: Int) async throws -> (Int, Data) {
        
        if sensor.type != .libre1 {
            print("readRaw() A3 command not supported by \(sensor.type)")
            throw NFCError.commandNotSupported
        }
        
        var buffer = Data()
        var remainingBytes = bytes
        
        while remainingBytes > 0 {
            
            let addressToRead = address + buffer.count
            let bytesToRead = min(remainingBytes, 24)
            
            var remainingWords = remainingBytes / 2
            if remainingBytes % 2 == 1 || ( remainingBytes % 2 == 0 && addressToRead % 2 == 1 ) { remainingWords += 1 }
            let wordsToRead = min(remainingWords, 12)   // real limit is 15
            
            let readRawCommand = NFCCommand(code: 0xA3, parameters: sensor.backdoor + [UInt8(addressToRead & 0xFF), UInt8(addressToRead >> 8), UInt8(wordsToRead)])
            
            if buffer.count == 0 { print("NFC: sending '\(readRawCommand.code.hex) \(readRawCommand.parameters.hex)' custom command (\(sensor.type) read raw)") }
            
            do {
                let output = try await connectedTag?.customCommand(requestFlags: .highDataRate, customCommandCode: readRawCommand.code, customRequestParameters: readRawCommand.parameters)
                var data = Data(output!)
                
                if addressToRead % 2 == 1 { data = data.subdata(in: 1 ..< data.count) }
                if data.count - bytesToRead == 1 { data = data.subdata(in: 0 ..< data.count - 1) }
                
                buffer += data
                remainingBytes -= data.count
                
            } catch {
                print("NFC: error while reading \(wordsToRead) words at raw memory 0x\(addressToRead.hex): \(error.localizedDescription)  ")
                throw NFCError.customCommandError
            }
        }
        
        return (address, buffer)
        
    }
    
    
    // Libre 1 only: overwrite mirrored FRAM blocks
    
    func writeRaw(_ address: Int, _ data: Data) async throws {
        
        if sensor.type != .libre1 {
            print("FRAM overwriting not supported by \(sensor.type)")
            throw NFCError.commandNotSupported
        }
        
        do {
            
            try await send(sensor.unlockCommand)
            
            let addressToRead = (address / 8) * 8
            let startOffset = address % 8
            let endAddressToRead = ((address + data.count - 1) / 8) * 8 + 7
            let blocksToRead = (endAddressToRead - addressToRead) / 8 + 1
            
            let (readAddress, readData) = try await readRaw(addressToRead, blocksToRead * 8)
            var msg = readData.hexDump(header: "NFC: blocks to overwrite:", address: readAddress)
            var bytesToWrite = readData
            bytesToWrite.replaceSubrange(startOffset ..< startOffset + data.count, with: data)
            msg += "\(bytesToWrite.hexDump(header: "\nwith blocks:", address: addressToRead))"
            print(msg)
            
            let startBlock = addressToRead / 8
            let blocks = bytesToWrite.count / 8
            
            if address >= 0xF860 {    // write to FRAM blocks
                
                let requestBlocks = 2    // 3 doesn't work
                
                let requests = Int(ceil(Double(blocks) / Double(requestBlocks)))
                let remainder = blocks % requestBlocks
                var blocksToWrite = [Data](repeating: Data(), count: blocks)
                
                for i in 0 ..< blocks {
                    blocksToWrite[i] = Data(bytesToWrite[i * 8 ... i * 8 + 7])
                }
                
                for i in 0 ..< requests {
                    
                    let startIndex = startBlock - 0xF860 / 8 + i * requestBlocks
                    let endIndex = startIndex + (i == requests - 1 ? (remainder == 0 ? requestBlocks : remainder) : requestBlocks) - (requestBlocks > 1 ? 1 : 0)
                    let blockRange = NSRange(startIndex ... endIndex)
                    
                    var dataBlocks = [Data]()
                    for j in startIndex ... endIndex { dataBlocks.append(blocksToWrite[j - startIndex]) }
                    
                    do {
                        try await connectedTag?.writeMultipleBlocks(requestFlags: .highDataRate, blockRange: blockRange, dataBlocks: dataBlocks)
                        print("NFC: wrote blocks 0x\(startIndex.hex) - 0x\(endIndex.hex) \(dataBlocks.reduce("", { $0 + $1.hex })) at 0x\(((startBlock + i * requestBlocks) * 8).hex)")
                    } catch {
                        print("NFC: error while writing multiple blocks 0x\(startIndex.hex)-0x\(endIndex.hex) \(dataBlocks.reduce("", { $0 + $1.hex })) at 0x\(((startBlock + i * requestBlocks) * 8).hex): \(error.localizedDescription)")
                        throw NFCError.write
                    }
                }
            }
            
            try await send(sensor.lockCommand)
            
        } catch {
            
            // TODO: manage errors
            
            print(error.localizedDescription)
        }
        
    }
    
    
    // TODO: write any Data size, not just a block
    
    func write(fromBlock startBlock: Int, _ data: Data) async throws {
        
        let startIndex = startBlock
        let endIndex = startIndex
        let blockRange = NSRange(startIndex ... endIndex)
        let dataBlocks = [data]
        
        do {
            try await connectedTag?.writeMultipleBlocks(requestFlags: .highDataRate, blockRange: blockRange, dataBlocks: dataBlocks)
            print("NFC: wrote blocks 0x\(startIndex.hex) - 0x\(endIndex.hex) \(dataBlocks.reduce("", { $0 + $1.hex }))")
        } catch {
            print("NFC: error while writing multiple blocks 0x\(startIndex.hex)-0x\(endIndex.hex) \(dataBlocks.reduce("", { $0 + $1.hex }))")
            throw NFCError.write
        }
        
    }
    
}

import Foundation
import CoreNFC
import PromiseKit

enum TransitTagType: CaseIterable {
    case feliCa
    case iso15693
    case iso7816
    case miFare
    case unknown
}

class TransitTag: CustomStringConvertible {
    var Serial: String?
    var Balance: Int?
  //  var Trips: [TransitTrip] = []
  //  var Refills: [TransitRefill] = []
    var ScannedAt: Date?
    var NFCType: TransitTagType?

    init(_ tagType: TransitTagType) {
        self.NFCType = tagType
        self.ScannedAt = Date()
    }

//    public var Events: [TransitEvent] {
//        return (self.Trips + self.Refills).sorted()
//    }

    var prettyBalance: String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter.string(from: (NSNumber(value: Double(self.Balance ?? 0)/100))) ?? "0"
    }

    func importTag(_ foundTag: NFCNDEFTag) -> Promise<TransitTag> {
        fatalError("importTag is not implemented!")
    }

    var description: String {
        return "Unknown tag"
    }

    var timezone: TimeZone {
        fatalError("TransitTag.timezone is not implemented!")
    }
}
