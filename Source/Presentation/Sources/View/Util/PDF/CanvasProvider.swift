//
//  CanvasProvider.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.03.
//

import Core

import Foundation
import PDFKit
import PencilKit

@MainActor
final class CanvasProvider: NSObject, @preconcurrency PDFPageOverlayViewProvider {
    
    private var canvasViewForPage: [PDFPage: PKCanvasView] = [:]
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        guard let canvasView = canvasViewForPage[page] else {
            let canvasView = PKCanvasView(frame: view.bounds).configured({
                $0.drawingPolicy = .anyInput
                $0.isUserInteractionEnabled = false
                $0.backgroundColor = .clear
                $0.tool = PKInkingTool(.pen, color: .red, width: 10)
            })
            canvasViewForPage[page] = canvasView
            return canvasView
        }
        return canvasView
    }
    
    func setTool(_ tool: CanvasTool) {
        canvasViewForPage.values.forEach({
            $0.tool = tool.pkTool
        })
    }
    
    func setUserInteractionEnabled(_ enabled: Bool) {
        canvasViewForPage.values.forEach({
            $0.isUserInteractionEnabled = enabled
        })
    }
}

enum CanvasTool {
    case pen
    case eraser
    
    var pkTool: PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen, color: .red, width: 10)
        case .eraser:
            return PKEraserTool(.vector)
        }
    }
}
