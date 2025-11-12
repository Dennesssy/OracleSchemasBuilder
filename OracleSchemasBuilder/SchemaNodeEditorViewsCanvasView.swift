import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var selectedNodeId: UUID?
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                CanvasGridView()
                
                // Connections
                ForEach(sessionManager.currentSession.connections) { connection in
                    ConnectionLineView(
                        connection: connection,
                        sourceNode: sessionManager.currentSession.node(with: connection.sourceNodeId),
                        targetNode: sessionManager.currentSession.node(with: connection.targetNodeId),
                        offset: offset,
                        scale: scale
                    )
                }
                
                // Nodes
                ForEach(sessionManager.currentSession.nodes) { node in
                    NodeView(node: node)
                        .onTapGesture {
                            selectedNodeId = node.id
                        }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if selectedNodeId == nil {
                            offset = CGSize(
                                width: offset.width + value.translation.width,
                                height: offset.height + value.translation.height
                            )
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(0.5, min(2.0, value))
                    }
            )
            .contextMenu {
                Button("Add Table Node") {
                    sessionManager.addTableNode(at: CGPoint(x: 100, y: 100))
                }
                
                Button("Add View Node") {
                    sessionManager.addViewNode(at: CGPoint(x: 100, y: 100))
                }
                
                Divider()
                
                Button("Reset View") {
                    withAnimation {
                        offset = .zero
                        scale = 1.0
                    }
                }
            }
        }
    }
}

struct CanvasGridView: View {
    let gridSize: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Vertical lines
                for x in stride(from: 0, through: geometry.size.width, by: gridSize) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: geometry.size.height, by: gridSize) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        }
    }
}

struct ConnectionLineView: View {
    let connection: Connection
    let sourceNode: SchemaNode?
    let targetNode: SchemaNode?
    let offset: CGSize
    let scale: CGFloat
    
    var body: some View {
        if let source = sourceNode, let target = targetNode {
            Path { path in
                let startPoint = CGPoint(
                    x: (source.position.x + 150) * scale + offset.width,
                    y: (source.position.y + 20) * scale + offset.height
                )
                let endPoint = CGPoint(
                    x: target.position.x * scale + offset.width,
                    y: (target.position.y + 20) * scale + offset.height
                )
                
                path.move(to: startPoint)
                
                // Create curved connection
                let midX = (startPoint.x + endPoint.x) / 2
                path.addCurve(
                    to: endPoint,
                    control1: CGPoint(x: midX, y: startPoint.y),
                    control2: CGPoint(x: midX, y: endPoint.y)
                )
            }
            .stroke(Color.accentColor, lineWidth: 2)
        }
    }
}

#Preview {
    CanvasView(selectedNodeId: .constant(nil))
        .environmentObject(SessionManager())
}
