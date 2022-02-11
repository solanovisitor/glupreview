//
//  constants.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 02/10/2021.
//

import Foundation

public var IsOnboarded_STR : String = "isOnboarded"
public var IsLoggedIn_STR : String = "isLoggedIn"
public var CurrentUser_STR : String = "userModel"
public var CurrentModelVersion_STR : String = "currentModelVersion"
public var CurrentModelLocalPath_STR : String = "currentModelLocalPath"

public var FIR_User_STR : String = "users"

public enum ScanStatus : String{
    case ready = "Ready to Scan!"
    case scanning = "Scanning!"
    case complete = "Scan Complete!"
    case rescan = "Re Scan!"
}

public let ML_Model = "https://drive.google.com/file/d/1XHZJbY-ZdASP2MH_UL9k8zPNdsCgZZ6m/view?usp=sharing"
