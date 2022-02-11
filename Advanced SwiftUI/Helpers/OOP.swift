import Foundation


// https://github.com/bubbledevteam/bubble-client-swift/blob/master/LibreSensor/


struct OOPServer {
    var siteURL: String
    var token: String
    var calibrationEndpoint: String?
    var historyEndpoint: String?
    var historyAndCalibrationEndpoint: String?
    var bleHistoryEndpoint: String?
    var activationEndpoint: String?
    var nfcAuthEndpoint: String?
    var nfcAuth2Endpoint: String?
    var nfcDataEndpoint: String?
    var nfcDataAlgorithmEndpoint: String?

    // TODO: new "callnox" endpoint replies with a GlucoseSpaceA2HistoryResponse specific for an 0xA2 Libre 1 patch


    // TODO: Gen2:

    // /openapi/xabetLibre libreoop2AndCalibrate("patchUid", "patchInfo", "content", "accesstoken" = "xabet-202104", "session")

    // /libre2ca/bleAuth ("p1", "patchUid", "authData")
    // /libre2ca/bleAuth2 ("p1", "authData")
    // /libre2ca/bleAlgorithm ("p1", "pwd", "bleData", "patchUid", "patchInfo")

    // /libre2ca/nfcAuth ("patchUid", "authData")
    // /libre2ca/nfcAuth2 ("p1", "authData")
    // /libre2ca/nfcData ("patchUid", "authData")
    // /libre2ca/nfcDataAlgorithm ("p1", "authData", "content", "patchUid", "patchInfo")


    static let `default`: OOPServer = OOPServer(siteURL: "https://www.glucose.space",
                                                token: "bubble-201907",
                                                calibrationEndpoint: "calibrateSensor",
                                                historyEndpoint: "libreoop2",
                                                historyAndCalibrationEndpoint: "libreoop2AndCalibrate",
                                                bleHistoryEndpoint: "libreoop2BleData",
                                                activationEndpoint: "activation")
    static let gen2: OOPServer = OOPServer(siteURL: "https://www.glucose.space",
                                           token: "xabet-202104",
                                           nfcAuthEndpoint: "libre2ca/nfcAuth",
                                           nfcAuth2Endpoint: "libre2ca/nfcAuth2",
                                           nfcDataEndpoint: "libre2ca/nfcData",
                                           nfcDataAlgorithmEndpoint: "libre2ca/nfcDataAlgorithm")

}

enum OOPError: LocalizedError {
    case noConnection
    case jsonDecoding

    var errorDescription: String? {
        switch self {
        case .noConnection: return "no connection"
        case .jsonDecoding: return "JSON decoding"
        }
    }
}

struct OOPGen2Response: Codable {
    let p1: Int
    let data: String
    let error: String
}


struct OOP {

    enum TrendArrow: Int, CustomStringConvertible, CaseIterable {
        case unknown        = -1
        case notDetermined  = 0
        case fallingQuickly = 1
        case falling        = 2
        case stable         = 3
        case rising         = 4
        case risingQuickly  = 5

        var description: String {
            switch self {
            case .notDetermined:  return "NOT_DETERMINED"
            case .fallingQuickly: return "FALLING_QUICKLY"
            case .falling:        return "FALLING"
            case .stable:         return "STABLE"
            case .rising:         return "RISING"
            case .risingQuickly:  return "RISING_QUICKLY"
            default:              return ""
            }
        }

        init(string: String) {
            for arrow in TrendArrow.allCases {
                if string == arrow.description {
                    self = arrow
                    return
                }
            }
            self = .unknown
        }

        var symbol: String {
            switch self {
            case .fallingQuickly: return "↓"
            case .falling:        return "↘︎"
            case .stable:         return "→"
            case .rising:         return "↗︎"
            case .risingQuickly:  return "↑"
            default:              return "---"
            }
        }
    }

    enum Alarm: Int, CustomStringConvertible, CaseIterable {
        case unknown              = -1
        case notDetermined        = 0
        case lowGlucose           = 1
        case projectedLowGlucose  = 2
        case glucoseOK            = 3
        case projectedHighGlucose = 4
        case highGlucose          = 5

        var description: String {
            switch self {
            case .notDetermined:        return "NOT_DETERMINED"
            case .lowGlucose:           return "LOW_GLUCOSE"
            case .projectedLowGlucose:  return "PROJECTED_LOW_GLUCOSE"
            case .glucoseOK:            return "GLUCOSE_OK"
            case .projectedHighGlucose: return "PROJECTED_HIGH_GLUCOSE"
            case .highGlucose:          return "HIGH_GLUCOSE"
            default:                    return ""
            }
        }

        init(string: String) {
            for alarm in Alarm.allCases {
                if string == alarm.description {
                    self = alarm
                    return
                }
            }
            self = .unknown
        }

        var shortDescription: String {
            switch self {
            case .lowGlucose:           return "LOW"
            case .projectedLowGlucose:  return "GOING LOW"
            case .glucoseOK:            return "OK"
            case .projectedHighGlucose: return "GOING HIGH"
            case .highGlucose:          return "HIGH"
            default:                    return ""
            }
        }
    }

}


// TODO: Codable
class OOPHistoryResponse {
    var currentGlucose: Int = 0
    var historyValues: [Glucose] = []
}

protocol GlucoseSpaceHistory {
    var isError: Bool { get }
    var sensorTime: Int? { get }
    var canGetParameters: Bool { get }
    var sensorState: SensorState { get }
    var valueError: Bool { get }
    func glucoseData(date: Date) -> (Glucose?, [Glucose])
}


struct OOPHistoryValue: Codable {
    let bg: Double
    let quality: Int
    let time: Int
}

struct GlucoseSpaceHistoricGlucose: Codable {
    let value: Int
    let dataQuality: Int    // if != 0, the value is erroneous
    let id: Int
}


class GlucoseSpaceHistoryResponse: OOPHistoryResponse, Codable { // TODO: implement the GlucoseSpaceHistory protocol
    var alarm: String?
    var esaMinutesToWait: Int?
    var historicGlucose: [GlucoseSpaceHistoricGlucose] = []
    var isActionable: Bool?
    var lsaDetected: Bool?
    var realTimeGlucose: GlucoseSpaceHistoricGlucose = GlucoseSpaceHistoricGlucose(value: 0, dataQuality: 0, id: 0)
    var trendArrow: String?
    var msg: String?
    var errcode: String?
    var endTime: Int?    // if != 0, the sensor expired

    enum Msg: String {
        case RESULT_SENSOR_STORAGE_STATE
        case RESCAN_SENSOR_BAD_CRC

        case TERMINATE_SENSOR_NORMAL_TERMINATED_STATE    // errcode: 10
        case TERMINATE_SENSOR_ERROR_TERMINATED_STATE
        case TERMINATE_SENSOR_CORRUPT_PAYLOAD

        // HTTP request bad arguments
        case FATAL_ERROR_BAD_ARGUMENTS

        // sensor state
        case TYPE_SENSOR_NOT_STARTED
        case TYPE_SENSOR_STARTING
        case TYPE_SENSOR_Expired
        case TYPE_SENSOR_END
        case TYPE_SENSOR_ERROR
        case TYPE_SENSOR_OK
        case TYPE_SENSOR_DETERMINED
    }


    func glucoseData(sensorAge: Int, readingDate: Date) -> [Glucose] {
        historyValues = [Glucose]()
        let startDate = readingDate - Double(sensorAge) * 60
        // let current = Glucose(realTimeGlucose.value, id: realTimeGlucose.id, date: startDate + Double(realTimeGlucose.id * 60))
        currentGlucose = realTimeGlucose.value
        var history = historicGlucose
        if (history.first?.id ?? 0) < (history.last?.id ?? 0) {
            history = history.reversed()
        }
        for g in history {
            let glucose = Glucose(g.value, id: g.id, date: startDate + Double(g.id * 60), source: "OOP" )
            historyValues.append(glucose)
        }
        return historyValues
    }
}


class GlucoseSpaceA2HistoryResponse: OOPHistoryResponse, Codable { // TODO: implement the GlucoseSpaceHistory protocol
    var errcode: Int?
    var list: [GlucoseSpaceList]?

    var content: OOPCurrentValue? {
        return list?.first?.content
    }
}

struct GlucoseSpaceList: Codable {
    let content: OOPCurrentValue?
    let timestamp: Int?
}

class GlucoseSpaceBLEDataResponse: OOPHistoryResponse, Codable { // TODO: implement the GlucoseSpaceHistory protocol
    var errcode: Int?
    var data: GlucoseSpaceHistoryResponse?
}

struct OOPCurrentValue: Codable {
    let currentTime: Int?
    let currentTrend: Int?
    let serialNumber: String?
    let historyValues: [OOPHistoryValue]?
    let currentBg: Double?
    let timestamp: Int?
    enum CodingKeys: String, CodingKey {
        case currentTime
        case currentTrend = "currenTrend"
        case serialNumber
        case historyValues = "historicBg"
        case currentBg
        case timestamp
    }
}


/// errcode: 4, msg: "content crc16 false"
/// errcode: 5, msg: "oop result error" with terminated sensors

struct OOPCalibrationResponse: Codable {
    let errcode: Int
    let parameters: Calibration
    enum CodingKeys: String, CodingKey {
        case errcode
        case parameters = "slope"
    }
}



// https://github.com/bubbledevteam/bubble-client-swift/blob/master/LibreSensor/LibreOOPResponse.swift

// TODO: when adding URLQueryItem(name: "appName", value: "diabox")
struct GetCalibrationStatusResult: Codable {
    var status: String?
    var slopeSlope: String?
    var slopeOffset: String?
    var offsetOffset: String?
    var offsetSlope: String?
    var uuid: String?
    var isValidForFooterWithReverseCRCs: Double?

    enum CodingKeys: String, CodingKey {
        case status
        case slopeSlope = "slope_slope"
        case slopeOffset = "slope_offset"
        case offsetOffset = "offset_offset"
        case offsetSlope = "offset_slope"
        case uuid
        case isValidForFooterWithReverseCRCs = "isValidForFooterWithReverseCRCs"
    }
}


struct GlucoseSpaceActivationResponse: Codable {
    let error: Int
    let productFamily: Int
    let activationCommand: Int
    let activationPayload: String
}


// TODO: reimplement by using await / async

func postToOOP(server: OOPServer, bytes: Data = Data(), date: Date = Date(), patchUid: SensorUid? = nil, patchInfo: PatchInfo? = nil, handler: @escaping (Data?, URLResponse?, Error?, [URLQueryItem]) -> Void) {
    var urlComponents = URLComponents(string: server.siteURL + "/" + (patchInfo == nil ? server.calibrationEndpoint! : (bytes.count > 0 ? (bytes.count > 46 ? server.historyEndpoint! : server.bleHistoryEndpoint!) : server.activationEndpoint!)))!
    var queryItems: [URLQueryItem] = bytes.count > 0 ? [URLQueryItem(name: "content", value: bytes.hex)] : []
    let date = Int64((date.timeIntervalSince1970 * 1000.0).rounded())
    if let patchInfo = patchInfo {
        queryItems += [
            URLQueryItem(name: "accesstoken", value: server.token),
            URLQueryItem(name: "patchUid", value: patchUid!.hex),
            URLQueryItem(name: "patchInfo", value: patchInfo.hex)
        ]
        if bytes.count == 46 {
            queryItems += [
                URLQueryItem(name: "appName", value: "Diabox"),
                URLQueryItem(name: "cgmType", value: "libre2ble")
            ]
        }
    } else {
        queryItems += [
            URLQueryItem(name: "token", value: server.token),
            URLQueryItem(name: "timestamp", value: "\(date)")
            // , URLQueryItem(name: "appName", value: "diabox")
        ]
    }
    urlComponents.queryItems = queryItems
    if let url = urlComponents.url {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                handler(data, response, error, queryItems)
            }
        }.resume()
    }
}


func postToOOP(server: OOPServer, bytes: Data = Data(), date: Date = Date(), patchUid: SensorUid? = nil, patchInfo: PatchInfo? = nil) async throws -> (Data?, URLResponse?, Error?, [URLQueryItem]) {
    return try await withUnsafeThrowingContinuation { continuation in
        postToOOP(server: server, bytes: bytes, date: date, patchUid: patchUid, patchInfo: patchInfo) { data, response, error, queryItems in
            if let error = error {
                continuation.resume(throwing: error)
                return
            } else {
                continuation.resume(returning: (data, response, error, queryItems))
            }
        }
    }
}


//extension MainDelegate {
//
//    func post(_ endpoint: String, _ jsonObject: Any) async throws -> Any {
//        let server = OOPServer.gen2
//        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject)
//        var request = URLRequest(url: URL(string: "\(server.siteURL)/\(endpoint)")!)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        do {
//            print("OOP: posting \(jsonData!.string) to \(request.url!.absoluteString)")
//            let (data, _) = try await URLSession.shared.data(for: request)
//            print("OOP: response: \(data.string)")
//            do {
//                switch endpoint {
//                case server.nfcDataEndpoint:
//                    let json = try JSONDecoder().decode(OOPGen2Response.self, from: data)
//                    print("OOP: decoded response: \(json)")
//                    return json
//                default:
//                    break
//                }
//            } catch {
//                print("OOP: error while decoding response: \(error.localizedDescription)")
//                throw OOPError.jsonDecoding
//            }
//        } catch {
//            print("OOP: server error: \(error.localizedDescription)")
//            throw OOPError.noConnection
//        }
//        return ["": ""]
//    }
//}


//extension Abbott {
//
//    // TODO: reimplement by using await / async
//
//    func testOOPBLEData() {
//        main.print("Sending BLE data to \(main.settings.oopServer.siteURL)/\(main.settings.oopServer.bleHistoryEndpoint!)...")
//        postToOOP(server: main.settings.oopServer, bytes: buffer, date: main.app.lastReadingDate, patchUid: sensor!.uid, patchInfo: sensor!.patchInfo) { data, response, error, parameters in
//            self.main.print("OOP: query parameters: \(parameters)")
//            if let data = data {
//                self.main.print("OOP: server BLE data response: \(data.string)")
//                if data.string.contains("errcode") {
//                    self.main.errorStatus("OOP BLE data error: \(data.string)")
//                } else {
//                    if let oopBLEData = try? JSONDecoder().decode(GlucoseSpaceBLEDataResponse.self, from: data) {
//                        let oopData = oopBLEData.data!
//                        let realTimeGlucose = oopData.realTimeGlucose.value
//                        if realTimeGlucose > 0 && !self.main.settings.calibrating {
//                            self.sensor!.currentGlucose = realTimeGlucose
//                        }
//                        self.main.app.oopAlarm = OOP.Alarm(string: oopData.alarm ?? "")
//                        self.main.app.oopTrend = OOP.TrendArrow(string: oopData.trendArrow ?? "")
//                        self.main.app.trendDeltaMinutes = 0
//                        let oopHistory = oopData.glucoseData(sensorAge: self.sensor!.age, readingDate: self.main.app.lastReadingDate)
//                        self.main.print("OOP: BLE data: realtime glucose: \(realTimeGlucose), history: \(oopHistory.map{ $0.value })".replacingOccurrences(of: "-1", with: "… "))
//                    } else {
//                        self.main.print("OOP: error while decoding JSON data")
//                        self.main.errorStatus("OOP server error: \(data.string)")
//                    }
//                }
//            } else {
//                self.main.print("OOP: connection failed")
//                self.main.errorStatus("OOP connection failed")
//            }
//            return
//        }
//    }
//
//}


extension Sensor {

    func testOOPActivation() async {
        // FIXME: await main.settings.oopServer
        let server = OOPServer.default
        print("OOP: sending sensor data to \(server.siteURL)/\(server.activationEndpoint!)...")
        do {
            let (data, _, _, queryItems) = try await postToOOP(server: server, patchUid: uid, patchInfo: patchInfo)
            print("OOP: query parameters: \(queryItems)")
            if let data = data {
                print("OOP: server activation response: \(data.string)")
                if let oopActivationResponse = try? JSONDecoder().decode(GlucoseSpaceActivationResponse.self, from: data) {
                    print("OOP: activation response: \(oopActivationResponse), activation command: \(UInt8(Int16(oopActivationResponse.activationCommand) & 0xFF).hex)")
                }
                print("\(type) computed activation command: \(activationCommand.code.hex.uppercased()) \(activationCommand.parameters.hex.uppercased())" )
            }
        } catch {
            // TODO: server error and response
            print("OOP: error while testing activation command: \(error.localizedDescription)")
        }

    }
}


//    print("Sending sensor data to \(settings.oopServer.siteURL)/\(settings.oopServer.calibrationEndpoint)...")
//    postToOOP(server: settings.oopServer, bytes: sensor.fram, date: app.lastReadingDate) { data, response, error, queryItems in
//        self.print("OOP: query parameters: \(queryItems)")
//        if let data = data {
//            self.print("OOP: server calibration response: \(data.string)")
//            if let oopCalibration = try? JSONDecoder().decode(OOPCalibrationResponse.self, from: data) {
//                if oopCalibration.parameters.offsetOffset == -2.0 &&
//                    oopCalibration.parameters.slopeSlope  == 0.0 &&
//                    oopCalibration.parameters.slopeOffset == 0.0 &&
//                    oopCalibration.parameters.offsetSlope == 0.0 {
//                    self.print("OOP: null calibration")
//                    self.errorStatus("OOP calibration not valid")
//                } else {
//                    self.settings.oopCalibration = oopCalibration.parameters
//                    if self.app.calibration == .empty || (self.app.calibration != self.settings.calibration) {
//                        self.app.calibration = oopCalibration.parameters
//                    }
//                }
//            } else {
//                if data.string.contains("errcode") {
//                    self.errorStatus("OOP calibration error: \(data.string)")
//                }
//            }
//
//        } else {
//            self.print("OOP: failed calibration")
//            self.errorStatus("OOP calibration failed")
//        }
//
//        // Reapply the current calibration even when the connection fails
//        self.applyCalibration(sensor: sensor)
//
//        if sensor.patchInfo.count == 0 {
//            self.didParseSensor(sensor)
//        }
//        return
//    }
//
//
//    if sensor.patchInfo.count > 0 {
//
//        var fram = sensor.encryptedFram.count > 0 ? sensor.encryptedFram : sensor.fram
//
//        guard fram.count >= 344 else {
//            print("NFC: partially scanned FRAM (\(fram.count)/344): cannot proceed to OOP")
//            return
//        }
//
//        // decryptFRAM() is symmetric: encrypt decrypted fram received from a Bubble
//        if (sensor.type == .libre2 || sensor.type == .libreUS14day) && sensor.encryptedFram.count == 0 {
//            fram = try! Data(Libre2.decryptFRAM(type: sensor.type, id: sensor.uid, info: sensor.patchInfo, data: fram))
//        }
//
//        print("Sending sensor data to \(settings.oopServer.siteURL)/\(settings.oopServer.historyEndpoint)...")
//
//        postToOOP(server: settings.oopServer, bytes: fram, date: app.lastReadingDate, patchUid: sensor.uid, patchInfo: sensor.patchInfo) { data, response, error, parameters in
//            self.print("OOP: query parameters: \(parameters)")
//            if let data = data {
//                self.print("OOP: server history response: \(data.string)")
//                if data.string.contains("errcode") {
//                    self.errorStatus("OOP history error: \(data.string)")
//                    self.history.values = []
//                } else {
//                    if let oopData = try? JSONDecoder().decode(GlucoseSpaceHistoryResponse.self, from: data) {
//                        let realTimeGlucose = oopData.realTimeGlucose.value
//                        if realTimeGlucose > 0 && !self.settings.calibrating {
//                            sensor.currentGlucose = realTimeGlucose
//                        }
//                        // PROJECTED_HIGH_GLUCOSE | HIGH_GLUCOSE | GLUCOSE_OK | LOW_GLUCOSE | PROJECTED_LOW_GLUCOSE | NOT_DETERMINED
//                        self.app.oopAlarm = oopData.alarm ?? ""
//                        // FALLING_QUICKLY | FALLING | STABLE | RISING | RISING_QUICKLY | NOT_DETERMINED
//                        self.app.oopTrend = oopData.trendArrow ?? ""
//                        self.app.trendDeltaMinutes = 0
//                        var oopHistory = oopData.glucoseData(sensorAge: sensor.age, readingDate: self.app.lastReadingDate)
//                        let oopHistoryCount = oopHistory.count
//                        if oopHistoryCount > 1 && self.history.rawValues.count > 0 {
//                            if oopHistory[0].value == 0 && oopHistory[1].id == self.history.rawValues[0].id {
//                                oopHistory.removeFirst()
//                                self.print("OOP: dropped the first null OOP value newer than the corresponding raw one")
//                            }
//                        }
//                        if oopHistoryCount > 0 {
//                            if oopHistoryCount < 32 { // new sensor
//                                oopHistory.append(contentsOf: [Glucose](repeating: Glucose(-1, date: self.app.lastReadingDate - Double(sensor.age) * 60), count: 32 - oopHistoryCount))
//                            }
//                            self.history.values = oopHistory
//                        } else {
//                            self.history.values = []
//                        }
//                        self.print("OOP: history values: \(oopHistory.map{ $0.value })".replacingOccurrences(of: "-1", with: "… "))
//                    } else {
//                        self.print("OOP: error while decoding JSON data")
//                        self.errorStatus("OOP server error: \(data.string)")
//                    }
//                }
//            } else {
//                self.history.values = []
//                self.print("OOP: connection failed")
//                self.errorStatus("OOP connection failed")
//            }
//            self.didParseSensor(sensor)
//            return
//        }
//    } else {
//        self.errorStatus("Patch info not available")
//        return
//    }
