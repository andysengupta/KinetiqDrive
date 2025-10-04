//
//  Kinetiq_DriveApp.swift
//  Kinetiq Drive
//
//  Created by Anand Sengupta on 04.10.25.
//

import SwiftUI

@main
struct Kinetiq_DriveApp: App {
    @StateObject private var motionSensingManager = MotionSensingManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionSensingManager)
        }
    }
}
