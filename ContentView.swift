import SwiftUI

/// The primary UI for the Schema Node Editor.  It composes the canvas,
/// inspector, and toolbar.  All model objects are injected via environment keep the view hierarchy clean.
struct ContentView: View {
    // Pull the observable objects from the environment.
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var canvasState: CanvasState
    
    var body: some View {
        HSplitView {
            // Left‑hand canvas – note the required `selectedNodeId` argument.
            CanvasView(selectedNodeId: canvasState.selectedNodeId)
                .environmentObject(sessionManager)
                .environmentObject(canvasState)
            
            // Right‑hand inspector
            InspectorView()
        }
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: addTable) {
                    Image(systemName: "plus.square.on.square")
                }
                .help("Add Table")
                
                Button(action: addView) {
                    Image(systemName: "plus.square.fill.on.square.fill")
                }
                .help("Add View")
                
                Divider()
                
                Button(action: canvasState.resetView) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .help("Reset Canvas")
            }
        }
    }
    
    // MARK: - Actions
    
    private func addTable() {
        let randomPos = CGPoint(
            x: Double.random(in: SchemaEditorConstants.File.defaultPositionRange),
            y: Double.random(in: SchemaEditorConstants.File.defaultPositionRange)
        )
        sessionManager.addTableNode(at: randomPos)
    }
    
    private func addView() {
        let randomPos = CGPoint(
            x: Double.random(in: SchemaEditorConstants.File.defaultPositionRange),
            y: Double.random(in: SchemaEditorConstants.File.defaultPositionRange)
        )
        sessionManager.addViewNode(at: randomPos)
    }
}
