//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.07.09.
//

import Foundation
import UIKit
import CoreMedia
import CoreImage

extension CMSampleBuffer {
    var ciImage: CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
    
    public func resize(to view: UIView) async -> CMSampleBuffer? {
        guard let (fromRect, toRect) = await MainActor.run(body: {
            view.getResizeRects()
        }) else {
            return nil
        }
        
        return ciImage?
            .generateCVPixelBuffer(from: fromRect, to: toRect)?
            .generateCMSampleBuffer(timingInfo: CMSampleTimingInfo(duration: duration, presentationTimeStamp: presentationTimeStamp, decodeTimeStamp: decodeTimeStamp))
    }
}

extension CIImage {
    
    func generateCVPixelBuffer(from: CGRect, to: CGRect) -> CVPixelBuffer? {
        let ciImageWidth = extent.width
        let ciImageHeight = extent.height
        
        
        let scaleX = ciImageWidth / from.width
        let scaleY = ciImageHeight / from.height
        
        let cropRect = CGRect(
            x: (to.origin.x - from.origin.x) * scaleX,
            y: (from.height - to.origin.y - to.height + from.origin.y) * scaleY,
            width: to.width * scaleX,
            height: to.height * scaleY
        )
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer!
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(extent.width), Int(extent.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            Log.log("CVPixelBufferCreateに失敗")
            return nil
        }
        
        let ciContext = CIContext()
        ciContext.render(self, to: pixelBuffer, bounds: cropRect, colorSpace: CGColorSpaceCreateDeviceRGB())
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

extension CVPixelBuffer {
    func generateCMSampleBuffer(timingInfo: CMSampleTimingInfo) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timimgInfo: CMSampleTimingInfo = timingInfo
        var videoInfo: CMVideoFormatDescription!
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: self, formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: self,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: videoInfo,
            sampleTiming: &timimgInfo,
            sampleBufferOut: &sampleBuffer
        )
        
        return sampleBuffer
    }
}

extension UIView {
    @MainActor
    func getResizeRects() -> (from: CGRect, to: CGRect)? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        let screenRect = window.screen.bounds
        
        let viewRect = frame
        return (from: screenRect, to: viewRect)
    }
}
