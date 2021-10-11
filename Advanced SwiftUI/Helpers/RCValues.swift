//
//  RCValues.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 10/10/2021.
//

import Foundation
import FirebaseRemoteConfig
enum ValueKey: String {
    case modelVersion
    case modelLink
}
class RCValues {
    static let sharedInstance = RCValues()
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    func value(forKey key: ValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.rawValue].stringValue!
    }
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            ValueKey.modelVersion.rawValue : "0.0",
            ValueKey.modelLink.rawValue : ML_Model,
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    func activateDebugMode() {
        let settings = RemoteConfigSettings()
        // WARNING: Don't actually do this in production!
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
    }
    func fetchCloudValues() {
        activateDebugMode()
        RemoteConfig.remoteConfig().fetch { [weak self] _, error in
            if let error = error {
                print("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            RemoteConfig.remoteConfig().activate { _, _ in
                print("Retrieved values from the cloud!")
                let appDefaults: [String: Any?] = [
                    ValueKey.modelVersion.rawValue : RemoteConfig.remoteConfig().configValue(forKey: "model_version").stringValue,
                    ValueKey.modelLink.rawValue : RemoteConfig.remoteConfig().configValue(forKey: "model_link").stringValue
                ]
                RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.ModelDownloaded,object: nil, userInfo: nil)
                }
            }
        }
    }
}
