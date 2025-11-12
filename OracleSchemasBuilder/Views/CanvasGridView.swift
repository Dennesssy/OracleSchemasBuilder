import SwiftUI

/// A simple background grid for the canvas.
struct CanvasGridView: View {
    var body: some View {
        Canvas { context, size in
            let spacing = Constants.Canvas.gridSpacing
            for x in stride(from: 0, to: size.width, by: spacing) {
                let rect = CGRect(x: x, y: 0, width: 0.5, height: size.height)
                context.stroke(Path(rect), with: .color(.gray.opacity(0.1)))
            }
            for y in stride(from: 0, to: size.height, by: spacing) {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 0.5)
                context.stroke(Path(rect), with: .color(.gray.opacity(0.1)))
            }
        }
    }
}
