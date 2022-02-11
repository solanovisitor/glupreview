import Foundation
import CoreBluetooth


enum DeviceType: CaseIterable, Hashable, Identifiable {

    case none
    case transmitter(TransmitterType)
    case watch(WatchType)

    static var allCases: [DeviceType] {
        return TransmitterType.allCases.map{.transmitter($0)} // + WatchType.allCases.map{.watch($0)}
    }

    var id: String {
        switch self {
        case .none:                  return "none"
        case .transmitter(let type): return type.id
        case .watch(let type):       return type.id
        }
    }

//    var type: AnyClass {
//        switch self {
//        case .none:                  return Device.self
//        case .transmitter(let type): return type.type
//        case .watch(let type):       return type.type
//        }
//    }
}


 
//enum TransmitterType: String, CaseIterable, Hashable, Codable, Identifiable {
//    case none, abbott, bubble, miaomiao
//    var id: String { rawValue }
//    var name: String {
//        switch self {
//        case .none:     return "Any"
//        case .abbott:   return Abbott.name
//        case .bubble:   return Bubble.name
//        case .miaomiao: return MiaoMiao.name
//        }
//    }
//    var type: AnyClass {
//        switch self {
//        case .none:     return Transmitter.self
//        case .abbott:   return Abbott.self
//        case .bubble:   return Bubble.self
//        case .miaomiao: return MiaoMiao.self
//        }
//    }
//}


 


 

 
