import SwiftUI

struct CanvasView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Binding var selectedNodeId: UUID?
    
    // Pan‑zoom is owned locally or could be driven by CanvasState
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CanvasGridView()
                
                ForEach(sessionManager.currentSession.connections) { connection in
                    ConnectionLineView(
                        connection: connection,
                        sourceNode: sessionManager.currentSession.node(with: connection.sourceNodeId),
                        targetNode: sessionManager.currentSession.node(with: connection.targetNodeId),
                        offset: offset,
                        scale: scale
                    )
                }
                
                ForEach(sessionManager.currentSession.nodes) { node in
                    // Assuming NodeView exists and takes a SchemaNode
                    Text(node.name) 
                        .position(x: node.position.x + offset.width, y: node.position.y + offset.height)
                        .onTapGesture {
                            sessionManager.selectNode(node.id)
                            selectedNodeId = node.id
                        }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if selectedNodeId == nil {
                            offset.width += value.translation.width
                            offset.height += value.translation.height
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let clamped = max(SchemaEditorConstants.Canvas.minZoom,
                                         min(SchemaEditorConstants.Canvas.maxZoom, value))
                        scale = clamped
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
