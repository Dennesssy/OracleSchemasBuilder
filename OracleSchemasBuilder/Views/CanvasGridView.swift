import SwiftUI

/// A simple background grid for the canvas.
struct CanvasGridView: View {
    var body: some View {
        Canvas { context, size in
            let spacing = Constants.Canvas.gridSpacing
            
            // Draw vertical lines
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.gray.opacity(0.1)), lineWidth: 0.5)
            }
            
            // Draw horizontal lines
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.gray.opacity(0.1)), lineWidth: 0.5)
            }
        }
    }
}
