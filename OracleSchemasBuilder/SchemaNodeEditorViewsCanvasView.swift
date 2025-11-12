import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Binding var selectedNodeId: UUID?
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
                        let newScale = max(Constants.Canvas.minZoom,
                                          min(Constants.Canvas.maxZoom,
                                              value))
                        scale = newScale
                    }
            )
            .accessibilityIdentifier("canvasView")
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
...
