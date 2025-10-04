//
//  MotionSensingManager.swift
//  Ride IQ
//
//  Created by Assistant on 04.10.25.
//

import Foundation
import CoreMotion
import Combine

final class MotionSensingManager: ObservableObject {
    @Published private(set) var isRunning: Bool = false

    // Acceleration in g (gravitational units)
    @Published private(set) var verticalAccelerationG: Double = 0
    @Published private(set) var lateralAccelerationG: Double = 0

    // Rotation rates in rad/s (device axes)
    @Published private(set) var rotationRateX: Double = 0
    @Published private(set) var rotationRateY: Double = 0
    @Published private(set) var rotationRateZ: Double = 0

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    init() {
        queue.qualityOfService = .userInitiated
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
    }

    func start() {
        guard !isRunning, motionManager.isDeviceMotionAvailable else { return }
        isRunning = true

        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            self.process(deviceMotion: motion)
        }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        motionManager.stopDeviceMotionUpdates()
    }

    func stop() {
        pause()
        reset()
    }

    private func reset() {
        DispatchQueue.main.async {
            self.verticalAccelerationG = 0
            self.lateralAccelerationG = 0
            self.rotationRateX = 0
            self.rotationRateY = 0
            self.rotationRateZ = 0
        }
    }

    private func process(deviceMotion: CMDeviceMotion) {
        // userAcceleration and gravity are expressed in g's aligned to device reference frame
        let ux = deviceMotion.userAcceleration.x
        let uy = deviceMotion.userAcceleration.y
        let uz = deviceMotion.userAcceleration.z

        let gx = deviceMotion.gravity.x
        let gy = deviceMotion.gravity.y
        let gz = deviceMotion.gravity.z

        // Normalize gravity to get up vector
        let gMag = max(Double.leastNonzeroMagnitude, sqrt(gx*gx + gy*gy + gz*gz))
        let upX = gx / gMag
        let upY = gy / gMag
        let upZ = gz / gMag

        // Vertical component = projection of userAcceleration on up vector
        let vertical = ux*upX + uy*upY + uz*upZ

        // Lateral vector = userAcceleration minus vertical component
        let lx = ux - vertical * upX
        let ly = uy - vertical * upY
        let lz = uz - vertical * upZ
        let lateral = sqrt(lx*lx + ly*ly + lz*lz)

        // Rotation rates
        let rrX = deviceMotion.rotationRate.x
        let rrY = deviceMotion.rotationRate.y
        let rrZ = deviceMotion.rotationRate.z

        DispatchQueue.main.async {
            self.verticalAccelerationG = vertical
            self.lateralAccelerationG = lateral
            self.rotationRateX = rrX
            self.rotationRateY = rrY
            self.rotationRateZ = rrZ
        }
    }
}


