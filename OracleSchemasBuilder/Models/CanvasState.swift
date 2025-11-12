import Foundation
import SwiftUI

@Observable
class CanvasState: ObservableObject {
    /// The UUID of the node currently selected on the canvas.
    var selectedNodeId: UUID?
}
