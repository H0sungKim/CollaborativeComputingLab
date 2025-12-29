//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.12.29.
//

import AVFoundation
import UIKit

extension UIDeviceOrientation {
    var avCaptureVideoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return nil
        }
    }
}
