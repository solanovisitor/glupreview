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
    
    
    @State private var isOnboarded: Bool = false
    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "YrBMLTUqlQKKcnYAtAYqssNGbNPFHxMI")
        isOnboarded = UserDefaults.standard.bool(forKey: isOnboarded_STR)
    }
    
    var body: some Scene {
        WindowGroup {
            if (isOnboarded){
                SignupView().environment(\.managedObjectContext, appDelegate.coreDataContext)
            } else {
                Onboarding().environment(\.managedObjectContext, appDelegate.coreDataContext)
            }
        }
    }
}
