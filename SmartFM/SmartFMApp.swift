//
//  SmartFMApp.swift
//  SmartFM
//
//  Created by I Smart Facitech PVT LTD on 15/10/23.
//

import SwiftUI
import GoogleMaps

@main
struct SmartFMApp: App {
    var body: some Scene {
        WindowGroup {
            if GMSServices.provideAPIKey("AIzaSyBJGpJhzzL5VqwseWSl9AwVbStK83Ztzis") {
                ContentView()
            }
        }
    }
}
