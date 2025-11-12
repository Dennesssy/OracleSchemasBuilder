import SwiftUI

/// Renders a single connection between two nodes.
struct ConnectionLineView: View {
    let connection: Connection
    let sourceNode: SchemaNode?
    let targetNode: SchemaNode?
    let offset: CGSize
    let scale: CGFloat
    
    var body: some View {
        if let src = sourceNode, let tgt = targetNode {
            Canvas { context, size in
                // Apply offset and scale to node positions
                let start = CGPoint(
                    x: src.position.x * scale + offset.width,
                    y: src.position.y * scale + offset.height
                )
                let end = CGPoint(
                    x: tgt.position.x * scale + offset.width,
                    y: tgt.position.y * scale + offset.height
                )
                CanvasRenderer.drawConnection(
                    connection,
                    fromPoint: start,
                    toPoint: end,
                    in: context.cgContext,
                    isSelected: false
                )
            }
            .accessibilityIdentifier("connectionLine_\(connection.id.uuidString)")
        }
    }
}
