import SwiftUI

final class CanvasState: ObservableObject {
    @Published var offset: CGSize = .zero
    @Published var scale: CGFloat = 1.0
    
    @Published var selectedNodeId: UUID? = nil
    @Published var selectedConnectionId: UUID? = nil
    @Published var hoveredNodeId: UUID? = nil
    
    // Convenience helpers used by the UI
    func resetView() {
        offset = .zero
        scale = 1.0
    }
}
