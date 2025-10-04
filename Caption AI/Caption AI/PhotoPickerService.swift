//
//  PhotoPickerService.swift
//  Caption Clash
//
//  Integrates PhotosUI for image selection with proper authorization
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class PhotoPickerService: ObservableObject {
    
    @Published var selectedImage: UIImage?
    @Published var isPickerPresented = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
        return status == .authorized || status == .limited
    }
    
    // MARK: - Image Selection
    
    func presentPicker() {
        isPickerPresented = true
    }
    
    func handleSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else {
            selectedImage = nil
            return
        }
        
        do {
            // Load image data
            if let data = try await item.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    // Process and optimize image
                    selectedImage = ImageUtils.processImage(image)
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            selectedImage = nil
        }
    }
    
    func clearSelection() {
        selectedImage = nil
    }
}

