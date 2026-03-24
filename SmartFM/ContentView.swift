//
//  ContentView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import SwiftUI

struct ContentView: View {
    //@State private var isLoggedIn: Bool = Globals.isLoggedIn()
    @AppStorage(Globals.IS_LOGGED_IN_KEY) private var isLoggedIn: String = ""
    @State private var isInitialized: Bool = false
    @State private var isLoading: Bool = true
    var body: some View {
        //if Globals.printAllKeyData() && Globals.initialize() && !isLoggedIn {
        //    LoginView()
        //} else {
        //    DashboardView()
        //}
        
        Group {
                    if isLoading {
                        ProgressView("Loading...")
                    } else if isLoggedIn != "1" {
                        LoginView()
                    } else {
                        DashboardView()
                    }
                }
                .onAppear {
                    // Start initialization in background
                    initializeApp()
                }
    }
    
    // Wrap async code inside a Task for iOS 14 compatibility
        func initializeApp() {
            Globals.printAllKeyData()
            
            Task {
                let success = await Globals.initialize()
                
                // Update UI on main thread
                await MainActor.run {
                    if success {
                        //isLoggedIn = Globals.isLoggedIn()
                        isInitialized = true
                    }
                    isLoading = false
                }
            }
        }

}

#Preview {
    ContentView()
}
