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
    
    @AppStorage(isOnboarded_STR) var onBoarded: Bool = false
    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "YrBMLTUqlQKKcnYAtAYqssNGbNPFHxMI")
    }
    
    var body: some Scene {
        WindowGroup {
            if (onBoarded){
                SignupView().environment(\.managedObjectContext, appDelegate.coreDataContext)
            } else {
                Onboarding().environment(\.managedObjectContext, appDelegate.coreDataContext)
            }
        }
    }
}
