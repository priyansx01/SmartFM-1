//
//  ContentView.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = Globals.isLoggedIn()
    var body: some View {
        if !isLoggedIn && Globals.printAllKeyData() {
            LoginView()
        } else {
            DashboardView()
        }
    }
    
}

#Preview {
    ContentView()
}
