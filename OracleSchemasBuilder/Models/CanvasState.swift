import Foundation
import SwiftUI

@Observable
class CanvasState {
    /// The UUID of the node currently selected on the canvas.
    var selectedNodeId: UUID?
    
    /// Pan offset for the canvas
    var offset: CGPoint = .zero
    
    /// Zoom scale for the canvas
    var scale: Double = 1.0
    
    /// Reset the canvas view to default position and scale
    func resetView() {
        offset = .zero
        scale = 1.0
    }
}
