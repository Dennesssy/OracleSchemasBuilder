import SwiftUI

/// Draws a grid background for the canvas.
struct CanvasGridView: View {
    var body: some View {
        Canvas { context, size in
            CanvasRenderer.drawGrid(
                in: context.cgContext,
                size: size,
                scale: 1.0
            )
        }
        .accessibilityIdentifier("canvasGridView")
    }
}
