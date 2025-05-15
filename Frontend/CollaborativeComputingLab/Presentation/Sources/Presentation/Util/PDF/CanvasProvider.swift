//
//  CanvasProvider.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.03.
//

import Foundation
import PDFKit

@MainActor
class CanvasProvider: NSObject, @preconcurrency PDFPageOverlayViewProvider {
    
    private var canvasViewForPage: [PDFPage: CanvasView] = [:]
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        guard let canvasView = canvasViewForPage[page] else {
            let canvasView = CanvasView()
            canvasView.backgroundColor = .clear
            canvasView.isUserInteractionEnabled = true
            canvasViewForPage[page] = canvasView
            return canvasView
        }
        return canvasView
    }
}
