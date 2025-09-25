//
//  ReplayKit+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.09.
//

import Domain

import Foundation
import UIKit
import CoreMedia
import CoreImage

extension UIView {
    @MainActor
    fileprivate func getCropRects() -> (from: CGRect, to: CGRect)? {
//        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
//        let screenRect = window.screen.bounds
        guard let screenRect = window?.screen.bounds else { return nil }
        let viewRect = self.convert(bounds, to: window)
        return (from: screenRect, to: viewRect)
    }
}

extension CMSampleBuffer {
    fileprivate var ciImage: CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: pixelBuffer)
    }
    
    public func crop(to view: UIView) async -> CMSampleBuffer? {
        guard let (fromRect, toRect) = await MainActor.run(body: {
            return view.getCropRects()
        }) else {
            return nil
        }
        
        return ciImage?
            .crop(from: fromRect, to: toRect)
            .generateCVPixelBuffer()?
            .generateCMSampleBuffer(timingInfo: CMSampleTimingInfo(duration: duration, presentationTimeStamp: presentationTimeStamp, decodeTimeStamp: decodeTimeStamp))
    }
}

extension CIImage {
    fileprivate func crop(from: CGRect, to: CGRect) -> CIImage {
        let ciImageWidth = extent.width
        let ciImageHeight = extent.height
        
        let scaleX = ciImageWidth / from.width
        let scaleY = ciImageHeight / from.height
        
        let cropRect = CGRect(
            x: (to.origin.x - from.origin.x) * scaleX,
            y: (from.height - to.origin.y - to.height) * scaleY,
            width: to.width * scaleX,
            height: to.height * scaleY
        )
        
        let croppedImage = self.cropped(to: cropRect).transformed(by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y))
        
        return croppedImage
    }
    
    fileprivate func generateCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer!
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(extent.width), Int(extent.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            Log.i("CVPixelBufferCreateに失敗")
            return nil
        }
        
        let ciContext = CIContext()
        ciContext.render(self, to: pixelBuffer, bounds: extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

extension CVPixelBuffer {
    fileprivate func generateCMSampleBuffer(timingInfo: CMSampleTimingInfo) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timimgInfo: CMSampleTimingInfo = timingInfo
        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: self, formatDescriptionOut: &videoInfo)
        guard let videoInfo else { return nil }
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
