import SwiftUI
import AppKit

/// A helper that draws nodes, connections and the background grid for the
/// canvas.  The original implementation used `UIBezierPath`, which is a
/// UIKit type that is not available on macOS.  Replaced with `NSBezierPath`.
class CanvasRenderer {
    
    // MARK: - Constants
    
    private static let headerHeight: CGFloat = 30
    private static let cornerRadius: CGFloat = 8
    private static let headerVerticalPadding: CGFloat = 4
    private static let headerHorizontalPadding: CGFloat = 8
    private static let fieldVerticalPadding: CGFloat = 4
    private static let fieldHorizontalPadding: CGFloat = 8
    
    // MARK: - Drawing a node
    
    static func drawNode(_ node: SchemaNode,
                         in context: CGContext,
                         isSelected: Bool,
                         isDarkMode: Bool) {
        let frame = node.frame
        // Background colour
        let backgroundColor = isSelected
            ? CGColor(gray: 0.2, alpha: 1.0)
            : CGColor(gray: 0.15, alpha: 1.0)
        context.setFillColor(backgroundColor)
        
        let path = NSBezierPath(roundedRect: frame,
                                xRadius: cornerRadius,
                                yRadius: cornerRadius)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Border
        let borderColor = isSelected
            ? CGColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
            : CGColor(gray: 0.3, alpha: 1.0)
        context.setStrokeColor(borderColor)
        context.setLineWidth(isSelected ? 2.5 : 1.5)
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Header background
        let headerRect = CGRect(x: frame.minX,
                                y: frame.maxY - headerHeight,
                                width: frame.width,
                                height: headerHeight)
        let headerColor = isSelected
            ? CGColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
            : CGColor(red: 0.15, green: 0.2, blue: 0.25, alpha: 1.0)
        context.setFillColor(headerColor)
        context.addPath(NSBezierPath(rect: headerRect).cgPath)
        context.fillPath()
        
        // Title text
        let title = node.name
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: isSelected ? NSColor.white : NSColor.black
        ]
        let titleRect = headerRect.insetBy(dx: headerHorizontalPadding, dy: headerVerticalPadding)
        title.draw(in: titleRect, withAttributes: attributes)
        
        // Fields list
        let fieldStartY = headerRect.minY - 12
        var fieldY = fieldStartY
        for field in node.fields {
            let fieldText = "\(field.name) \(field.typeDescription)"
            let fieldAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.gray
            ]
            let fieldRect = CGRect(x: frame.minX + fieldHorizontalPadding,
                                   y: fieldY,
                                   width: frame.width - 2 * fieldHorizontalPadding,
                                   height: 14)
            fieldText.draw(in: fieldRect, withAttributes: fieldAttributes)
            fieldY -= 16
        }
    }
    
    // MARK: - Drawing a connection
    
    static func drawConnection(_ connection: Connection,
                               fromPoint: CGPoint,
                               toPoint: CGPoint,
                               in context: CGContext,
                               isSelected: Bool) {
        let color = isSelected
            ? CGColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
            : CGColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 0.6)
        context.setStrokeColor(color)
        context.setLineWidth(isSelected ? 2.5 : 2.0)
        context.setLineCap(.round)
        
        // Curved path using macOS API
        let midX = (fromPoint.x + toPoint.x) / 2
        let path = NSBezierPath()
        path.move(to: fromPoint)
        path.curve(to: toPoint,
                   controlPoint1: CGPoint(x: midX, y: fromPoint.y),
                   controlPoint2: CGPoint(x: midX, y: toPoint.y))
        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    // MARK: - Drawing the background grid
    
    static func drawGrid(in context: CGContext, size: CGSize, scale: CGFloat) {
        let gridSize: CGFloat = 20
        context.setStrokeColor(CGColor(gray: 0.85, alpha: 0.5))
        context.setLineWidth(0.5)
        
        for x in stride(from: 0, through: size.width, by: gridSize) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
        }
        for y in stride(from: 0, through: size.height, by: gridSize) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.strokePath()
    }
}
