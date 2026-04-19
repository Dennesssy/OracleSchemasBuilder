import SwiftUI
import CoreGraphics
import Combine // Required for @Published

/// Global canvas state used throughout the editor.
final class CanvasState: ObservableObject {
    // MARK: - Published State
    
    @Published var selectedNodeId: UUID? = nil
    @Published var zoomScale: CGFloat = SchemaEditorConstants.Canvas.defaultZoom
    @Published var offset: CGSize = .zero
    @Published var scale: Double = 1.0 // Added this property
    
    // MARK: - Computed Transform
    
    var transform: CGAffineTransform {
        CGAffineTransform(translationX: offset.width, y: offset.height)
            .scaledBy(x: zoomScale, y: zoomScale)
    }
    
    // MARK: - Helpers
    
    func resetView() {
        zoomScale = SchemaEditorConstants.Canvas.defaultZoom
        offset = .zero
    }
}
