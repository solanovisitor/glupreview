//
//  constants.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 02/10/2021.
//

import Foundation

public var isOnboarded_STR : String = "isOnboarded"

public enum ScanStatus : String{
    case ready = "Ready to Scan!"
    case scanning = "Scanning!"
    case complete = "Scan Complete!"
    case rescan = "Re Scan!"
}
