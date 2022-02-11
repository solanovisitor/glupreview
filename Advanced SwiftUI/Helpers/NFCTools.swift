import Foundation


// https://github.com/ivalkou/LibreTools/blob/master/Sources/LibreTools/NFC/NFCManager.swift


#if !os(watchOS) && !targetEnvironment(macCatalyst)

import CoreNFC

extension NFCReader {


    func execute(_ taskRequest: TaskRequest) async throws {

        switch taskRequest {


        case .reset:

            if sensor.type != .libre1 && sensor.type != .libreProH {
                print("E0 reset command not supported by \(sensor.type)")
                throw NFCError.commandNotSupported
            }

            switch sensor.type {


            case .libre1:

                let (commandsFramAddress, commmandsFram) = try await readRaw(0xF860 + 43 * 8, 195 * 8)

                let e0Offset = 0xFFB6 - commandsFramAddress
                let a1Offset = 0xFFC6 - commandsFramAddress
                let e0Address = UInt16(commmandsFram[e0Offset ... e0Offset + 1])
                let a1Address = UInt16(commmandsFram[a1Offset ... a1Offset + 1])

                print("E0 and A1 commands' addresses: \(e0Address.hex) \(a1Address.hex) (should be fbae and f9ba)")

                let originalCRC = crc16(commmandsFram[2 ..< 195 * 8])
                print("Commands section CRC: \(UInt16(commmandsFram[0...1]).hex), computed: \(originalCRC.hex) (should be 429e or f9ae for a Libre 1 A2)")

                var patchedFram = Data(commmandsFram)
                patchedFram[a1Offset ... a1Offset + 1] = e0Address.data
                let patchedCRC = crc16(patchedFram[2 ..< 195 * 8])
                patchedFram[0 ... 1] = patchedCRC.data

                print("CRC after replacing the A1 command address with E0: \(patchedCRC.hex) (should be 6e01 or d531 for a Libre 1 A2)")

                do {
                    try await writeRaw(commandsFramAddress + a1Offset, e0Address.data)
                    try await writeRaw(commandsFramAddress, patchedCRC.data)
                    try await send(sensor.getPatchInfoCommand)
                    try await writeRaw(commandsFramAddress + a1Offset, a1Address.data)
                    try await writeRaw(commandsFramAddress, originalCRC.data)

                    let (start, data) = try await read(fromBlock: 0, count: 43)
                    print(data.hexDump(header: "NFC: did reset FRAM:", startingBlock: start))
                    sensor.fram = Data(data)
                } catch {

                    // TODO: manage errors and verify integrity

                }


            case .libreProH:

                // TODO: use Libre Pro E0 instead of simply overwriting the FRAM with fresh values

                do {
                    try await send(sensor.unlockCommand)

                    // header
                    try await write(fromBlock: 0x00, Data([0x6A, 0xBC, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00]))
                    try await write(fromBlock: 0x01, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                    try await write(fromBlock: 0x02, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                    try await write(fromBlock: 0x03, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                    try await write(fromBlock: 0x04, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))

                    // footer
                    try await write(fromBlock: 0x05, Data([0x99, 0xDD, 0x10, 0x00, 0x14, 0x08, 0xC0, 0x4E]))
                    try await write(fromBlock: 0x06, Data([0x14, 0x03, 0x96, 0x80, 0x5A, 0x00, 0xED, 0xA6]))
                    try await write(fromBlock: 0x07, Data([0x12, 0x56, 0xDA, 0xA0, 0x04, 0x0C, 0xD8, 0x66]))
                    try await write(fromBlock: 0x08, Data([0x29, 0x02, 0xC8, 0x18, 0x00, 0x00, 0x00, 0x00]))

                    // age, trend and history indexes
                    try await write(fromBlock: 0x09, Data([0xBD, 0xD1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                    // trend
                    for b in 0x0A ... 0x15 {
                        try await write(fromBlock: b, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
                    }

                    // duplicated in activation
                    var readCommand = sensor.readBlockCommand
                    readCommand.parameters = Data("DF 04".bytes)
                    var output = try await send(readCommand)
                    print("NFC: 'B0 read 0x04DF' command output: \(output.hex)")
                    var writeCommand = sensor.writeBlockCommand
                    writeCommand.parameters = Data("DF 04 20 00 DF 88 00 00 00 00".bytes)
                    output = try await send(writeCommand)
                    print("NFC: 'B1 write' command output: \(output.hex)")
                    output = try await send(readCommand)
                    print("NFC: 'B0 read 0x04DF' command output: \(output.hex)")

                    try await send(sensor.lockCommand)

                } catch {

                    // TODO: manage errors and verify integrity

                }


            default:
                break

            }


        case .prolong:

            if sensor.type != .libre1 {
                print("FRAM overwriting not supported by \(sensor.type)")
                throw NFCError.commandNotSupported
            }

            let (footerAddress, footerFram) = try await readRaw(0xF860 + 40 * 8, 3 * 8)

            let maxLifeOffset = 6
            let maxLife = Int(footerFram[maxLifeOffset]) + Int(footerFram[maxLifeOffset + 1]) << 8
            print("\(sensor.type) current maximum life: \(maxLife) minutes (\(maxLife.formattedInterval))")

            var patchedFram = Data(footerFram)
            patchedFram[maxLifeOffset ... maxLifeOffset + 1] = Data([0xFF, 0xFF])
            let patchedCRC = crc16(patchedFram[2 ..< 3 * 8])
            patchedFram[0 ... 1] = patchedCRC.data

            do {
                try await writeRaw(footerAddress + maxLifeOffset, patchedFram[maxLifeOffset ... maxLifeOffset + 1])
                try await writeRaw(footerAddress, patchedCRC.data)

                let (_, data) = try await read(fromBlock: 0, count: 43)
                print(Data(data.suffix(3 * 8)).hexDump(header: "NFC: did overwite FRAM footer:", startingBlock: 40))
                sensor.fram = Data(data)
            } catch {

                // TODO: manage errors and verify integrity

            }


        case .unlock:

            if sensor.securityGeneration < 1 {
                print("'A1 1A unlock' command not supported by \(sensor.type)")
                throw NFCError.commandNotSupported
            }

            do {
                let output = try await send(sensor.unlockCommand)

                // Libre 2
                if output.count == 0 {
                    print("NFC: FRAM should have been decrypted in-place")
                }

            } catch {

                // TODO: manage errors and verify integrity

            }

            let (_, data) = try await read(fromBlock: 0, count: 43)
            sensor.fram = Data(data)


        case .activate:

            if sensor.securityGeneration > 1 {
                print("Activating a \(sensor.type) is not supported")
                throw NFCError.commandNotSupported
            }

            do {
//                if await sensor.main.settings.debugLevel > 0 {
//                    await sensor.testOOPActivation()
//                }


                if sensor.type == .libreProH {
                    var readCommand = sensor.readBlockCommand
                    readCommand.parameters = Data("DF 04".bytes)
                    var output = try await send(readCommand)
                    print("NFC: 'B0 read 0x04DF' command output: \(output.hex)")
                    try await send(sensor.unlockCommand)
                    var writeCommand = sensor.writeBlockCommand
                    writeCommand.parameters = Data("DF 04 20 00 DF 88 00 00 00 00".bytes)
                    output = try await send(writeCommand)
                    print("NFC: 'B1 write' command output: \(output.hex)")
                    try await send(sensor.lockCommand)
                    output = try await send(readCommand)
                    print("NFC: 'B0 read 0x04DF' command output: \(output.hex)")
                }

                let output = try await send(sensor.activationCommand)
                print("NFC: after trying to activate received \(output.hex) for the patch info \(sensor.patchInfo.hex)")

                // Libre 2
                if output.count == 4 {
                    // receiving 9d081000 for a patchInfo 9d0830010000
                    print("NFC: \(sensor.type) should be activated and warming up")
                }

            } catch {

                // TODO: manage errors and verify integrity

            }

            let (_, data) = try await read(fromBlock: 0, count: 43)
            sensor.fram = Data(data)


        default:
            break

        }

    }

}

#endif    // !os(watchOS) && !targetEnvironment(macCatalyst)
