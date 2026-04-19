import Foundation
import CoreGraphics

/// Represents a relationship (edge) between two `SchemaNode`s.
struct Connection: Identifiable, Codable {
    let id: UUID = UUID()
    var sourceNodeId: UUID
    var targetNodeId: UUID
    
    /// Optional label (e.g. FK name) displayed on the edge.
    var label: String? = nil
    
    /// Determines the visual style of the connection.
    enum Style: String, Codable {
        case solid
        case dashed
    }
    var style: Style = .solid
}
