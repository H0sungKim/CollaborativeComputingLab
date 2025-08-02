//
//  CameraPreviewView.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.11.
//

import Domain

@preconcurrency import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    
    private let session: AVCaptureSession = AVCaptureSession()
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override var isHidden: Bool {
        didSet {
            isHidden ? stop() : start()
        }
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                Log.e("Cannot add input.")
            }
        } catch {
            Log.e(error.localizedDescription)
        }
        
        session.commitConfiguration()
        
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func start() {
        let session = session
        DispatchQueue.global().async {
            session.startRunning()
        }
    }
    
    func stop() {
        let session = session
        DispatchQueue.global().async {
            session.stopRunning()
        }
    }
    
    @available(iOS 17, *)
    func rotate(orientation: UIDeviceOrientation) {
        let angle: CGFloat
        switch orientation {
        case .portrait:
            angle = 90
        case .portraitUpsideDown:
            angle = 270
        case .landscapeLeft:
            angle = 180
        case .landscapeRight:
            angle = 0
        default:
            return
        }
        
        if let condition = previewLayer.connection?.isVideoRotationAngleSupported(angle), condition {
            previewLayer.connection?.videoRotationAngle = angle
        }
    }
}
