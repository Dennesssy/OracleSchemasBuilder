import SwiftUI

/// Renders a straight line between two nodes.
struct ConnectionLineView: View {
    let connection: Connection
    let sourceNode: SchemaNode?
    let targetNode: SchemaNode?
    let offset: CGSize
    let scale: CGFloat

    var body: some View {
        if let source = sourceNode, let target = targetNode {
            Path { path in
                let start = CGPoint(
                    x: source.position.x + offset.width,
                    y: source.position.y + offset.height
                )
                let end = CGPoint(
                    x: target.position.x + offset.width,
                    y: target.position.y + offset.height
                )
                path.move(to: start)
                path.addLine(to: end)
            }
            .stroke(connection.connectionType == .oneToMany ? Color.accentColor : Color.gray, lineWidth: 2)
        }
    }
}
