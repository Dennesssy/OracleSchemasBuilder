//
//  CanvasRenderer.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import SwiftUI
import CoreGraphics

struct CanvasRenderer {
    static func drawConnection(
        from sourcePoint: CGPoint,
        to targetPoint: CGPoint,
        in context: GraphicsContext
    ) {
        var path = Path()
        
        let controlPointOffset = abs(targetPoint.x - sourcePoint.x) * 0.5
        
        path.move(to: sourcePoint)
        path.addCurve(
            to: targetPoint,
            control1: CGPoint(x: sourcePoint.x + controlPointOffset, y: sourcePoint.y),
            control2: CGPoint(x: targetPoint.x - controlPointOffset, y: targetPoint.y)
        )
        
        context.stroke(
            path,
            with: .color(.blue),
            lineWidth: 2
        )
        
        // Draw arrow at the end
        drawArrowhead(at: targetPoint, angle: calculateAngle(from: sourcePoint, to: targetPoint), in: context)
    }
    
    private static func drawArrowhead(at point: CGPoint, angle: Double, in context: GraphicsContext) {
        var path = Path()
        
        let arrowSize: CGFloat = 10
        let arrowAngle: Double = .pi / 6
        
        let point1 = CGPoint(
            x: point.x - arrowSize * cos(angle - arrowAngle),
            y: point.y - arrowSize * sin(angle - arrowAngle)
        )
        
        let point2 = CGPoint(
            x: point.x - arrowSize * cos(angle + arrowAngle),
            y: point.y - arrowSize * sin(angle + arrowAngle)
        )
        
        path.move(to: point1)
        path.addLine(to: point)
        path.addLine(to: point2)
        
        context.stroke(
            path,
            with: .color(.blue),
            lineWidth: 2
        )
    }
    
    private static func calculateAngle(from start: CGPoint, to end: CGPoint) -> Double {
        return atan2(end.y - start.y, end.x - start.x)
    }
    
    static func gridPattern(size: CGSize, spacing: CGFloat = 20) -> Path {
        var path = Path()
        
        let columns = Int(size.width / spacing) + 1
        let rows = Int(size.height / spacing) + 1
        
        for column in 0..<columns {
            let x = CGFloat(column) * spacing
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }
        
        for row in 0..<rows {
            let y = CGFloat(row) * spacing
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        return path
    }
}
