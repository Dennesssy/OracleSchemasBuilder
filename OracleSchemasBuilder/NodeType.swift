import Foundation

/// Represents the type of a schema node (table, view, etc.).
enum NodeType: String, Codable, CaseIterable {
    case table
    case view
    case procedure
    case function
}
