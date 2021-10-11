//
//  Advanced_SwiftUIApp.swift
//  Advanced SwiftUI
//
//  Created by Sai Kambampati on 3/22/21.
//

import SwiftUI
import Firebase
import Purchases
import CoreData

@main
struct Advanced_SwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage(IsOnboarded_STR) var onBoarded: Bool = false
    @AppStorage(IsLoggedIn_STR) var isLoggedIn : Bool =  false
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isModelDownloaded: Bool = false
    
    init() {
        FirebaseApp.configure()
        _ = RCValues.sharedInstance
        Purchases.configure(withAPIKey: "YrBMLTUqlQKKcnYAtAYqssNGbNPFHxMI")
        
    }
    
    var body: some Scene {
        WindowGroup {
            if (isLoggedIn){
                let cloudVersion = Double(RCValues.sharedInstance.value(forKey: .modelVersion))
                let currentVersion = Double(UserDefaults.standard.string(forKey: CurrentModelVersion_STR) ?? "0.0")
                if (currentVersion != nil && cloudVersion != nil && currentVersion! > cloudVersion!) {
                    Dashboard().environment(\.managedObjectContext, appDelegate.coreDataContext)
                } else {
                    ModelDownloadView().environment(\.managedObjectContext, appDelegate.coreDataContext)
                }
            } else if (onBoarded){
                SignupView().environment(\.managedObjectContext, appDelegate.coreDataContext)
            } else {
                Onboarding().environment(\.managedObjectContext, appDelegate.coreDataContext)
            }
        }
    }
}
