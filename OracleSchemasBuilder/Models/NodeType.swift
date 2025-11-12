import Foundation

/// Represents the type of a schema node (table, view, etc.).
enum NodeType: String, Codable, CaseIterable {
    case table = "Table"
    case view = "View"
    // Additional node types can be added here if needed.
}
