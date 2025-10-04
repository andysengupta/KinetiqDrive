//
//  Kinetiq_DriveApp.swift
//  Kinetiq Drive
//
//  Created by Anand Sengupta on 04.10.25.
//

import SwiftUI
import Combine

@main
struct Kinetiq_DriveApp: App {
    @StateObject private var motionSensingManager = MotionSensingManager()
    @StateObject private var analysisViewModel: AnalysisViewModel
    @StateObject private var rideStore = RideStore()
    @StateObject private var locationManager = LocationManager()
    @State private var showSplash: Bool = true

    init() {
        let sensing = MotionSensingManager()
        _motionSensingManager = StateObject(wrappedValue: sensing)
        _analysisViewModel = StateObject(wrappedValue: AnalysisViewModel(sensing: sensing))
    }
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView { withAnimation(.easeOut(duration: 0.4)) { showSplash = false } }
                } else {
                    RootTabView()
                }
            }
            .environmentObject(motionSensingManager)
            .environmentObject(analysisViewModel)
            .environmentObject(rideStore)
            .environmentObject(locationManager)
        }
    }
}
