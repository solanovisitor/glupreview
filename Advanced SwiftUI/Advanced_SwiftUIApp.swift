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
    
    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "YrBMLTUqlQKKcnYAtAYqssNGbNPFHxMI")
    }
    
    var body: some Scene {
        WindowGroup {
<<<<<<< HEAD
            //SignupView()
            OnboardingView().environment(\.managedObjectContext, appDelegate.coreDataContext)
        }
        
        
=======
            Onboarding()
                .environment(\.managedObjectContext, appDelegate.coreDataContext)
        }
>>>>>>> 79002f2eb20010c5ed2ece2c33a36afe476e96da
    }
}
