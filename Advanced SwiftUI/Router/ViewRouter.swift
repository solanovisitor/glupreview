//
//  ViewRouter.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 06/10/2021.
//

import Foundation
class ViewRouter: ObservableObject {
    
    @Published var currentPage: String
    init() {
        if !UserDefaults.standard.bool(forKey: isOnboarded_STR) {
            UserDefaults.standard.set(true, forKey: isOnboarded_STR)
            currentPage = "onboarding"
        } else {
            currentPage = "dashboard"
        }
    }
    
}
