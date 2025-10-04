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
    @StateObject private var analysisViewModel: AnalysisViewModel

    init() {
        let sensing = MotionSensingManager()
        _motionSensingManager = StateObject(wrappedValue: sensing)
        _analysisViewModel = StateObject(wrappedValue: AnalysisViewModel(sensing: sensing))
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionSensingManager)
                .environmentObject(analysisViewModel)
        }
    }
}
