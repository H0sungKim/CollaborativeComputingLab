//
//  CanvasView.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.03.
//

import Core

import UIKit

final class CanvasView: UIView {
    var strokeWidth: Float = 4
    var strokeColor: UIColor = .black
    var paths: [UIBezierPath] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let point = touches.first?.location(in: self) else { return }
        let path = UIBezierPath().configured({
            $0.lineCapStyle = .round
            $0.lineJoinStyle = .round
            $0.lineWidth = CGFloat(strokeWidth)
            $0.move(to: point)
        })
        paths.append(path)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let point = touches.first?.location(in: self) else { return }
        guard let lastPath = paths.popLast() else { return }
        lastPath.addLine(to: point)
        paths.append(lastPath)
        setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        strokeColor.setStroke()
        paths.forEach({ path in
            path.stroke()
        })
    }
    
    func undo() {
        _ = paths.popLast()
        setNeedsDisplay()
    }
    
    func clear() {
        paths.removeAll()
        setNeedsDisplay()
    }
}
