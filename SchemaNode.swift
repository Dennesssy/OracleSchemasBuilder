import Foundation
import CoreGraphics
import SwiftUI

/// A single schema element (e.g. a table or a view).
struct SchemaNode: Identifiable, Codable {
    enum NodeType: String, Codable {
        case table
        case view
        case sequence
        case function
        case procedure
        case package
    }
    
    let id: UUID
    var name: String
    var type: NodeType = .table
    var position: CGPoint
    var fields: [Field] = []
    var color: NodeColor = .blue
}

struct Field: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var dataType: String
    var isPrimaryKey: Bool = false
    var isNullable: Bool = true
}

enum NodeColor: String, Codable {
    case blue, green, orange, purple, red
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        }
    }
}
