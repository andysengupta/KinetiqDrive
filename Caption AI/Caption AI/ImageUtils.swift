//
//  ImageUtils.swift
//  Caption Clash
//
//  Image processing utilities: downscaling, orientation fix, compression
//  Memory-efficient processing for on-device AI
//

import UIKit
import CoreGraphics

struct ImageUtils {
    
    // MARK: - Configuration
    
    static let maxImageDimension: CGFloat = 2048
    static let thumbnailMaxDimension: CGFloat = 512
    static let compressionQuality: CGFloat = 0.85
    
    // MARK: - Main Processing
    
    /// Process image for AI: downscale, fix orientation, optimize memory
    static func processImage(_ image: UIImage) -> UIImage {
        // Fix orientation first
        let orientationFixed = fixOrientation(image)
        
        // Downscale if needed
        let downscaled = downscale(orientationFixed, maxDimension: maxImageDimension)
        
        return downscaled
    }
    
    /// Create low-res thumbnail for storage (privacy-conscious)
    static func createThumbnail(_ image: UIImage) -> Data? {
        let thumbnail = downscale(image, maxDimension: thumbnailMaxDimension)
        return thumbnail.jpegData(compressionQuality: 0.7)
    }
    
    // MARK: - Downscaling
    
    static func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // Check if downscaling needed
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // Render at new size
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resized
    }
    
    // MARK: - Orientation Fix
    
    /// Fix image orientation from camera/photos
    static func fixOrientation(_ image: UIImage) -> UIImage {
        // If already up, return as-is
        guard image.imageOrientation != .up else {
            return image
        }
        
        // Render with correct orientation
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let fixedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return fixedImage
    }
    
    // MARK: - Format Conversion
    
    /// Convert to JPEG for compatibility
    static func toJPEG(_ image: UIImage, quality: CGFloat = compressionQuality) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    /// Estimate memory footprint
    static func estimateMemoryFootprint(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.width * cgImage.height * 4 // RGBA bytes
    }
}

