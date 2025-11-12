import Foundation
import SwiftUI

/// Represents a database table, view, or other schema object.
@Observable
class SchemaNode: Identifiable, Codable {
    let id: UUID
    var name: String
    var nodeType: NodeType
    var position: CGPoint
    var fields: [TableField]
    var notes: String
    var schema: String
    var color: NodeColor
    var outgoingConnections: [UUID] // IDs of connected nodes
    
    init(
        id: UUID = UUID(),
        name: String = "NewTable",
        nodeType: NodeType = .table,
        position: CGPoint = .zero,
        fields: [TableField] = [],
        notes: String = "",
        schema: String = "PUBLIC",
        color: NodeColor = .blue,
        outgoingConnections: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.nodeType = nodeType
        self.position = position
        self.fields = fields
        self.notes = notes
        self.schema = schema
        self.color = color
        self.outgoingConnections = outgoingConnections
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, nodeType, position, fields, notes, schema, color, outgoingConnections
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
        
        let posArray = try container.decode([CGFloat].self, forKey: .position)
        position = CGPoint(x: posArray[0], y: posArray[1])
        
        fields = try container.decode([TableField].self, forKey: .fields)
        notes = try container.decode(String.self, forKey: .notes)
        schema = try container.decode(String.self, forKey: .schema)
        color = try container.decode(NodeColor.self, forKey: .color)
        outgoingConnections = try container.decode([UUID].self, forKey: .outgoingConnections)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode([position.x, position.y], forKey: .position)
        try container.encode(fields, forKey: .fields)
        try container.encode(notes, forKey: .notes)
        try container.encode(schema, forKey: .schema)
        try container.encode(color, forKey: .color)
        try container.encode(outgoingConnections, forKey: .outgoingConnections)
    }
    
    // MARK: - Helpers
    
    /// Alias used by the UI for the table name field
    var tableName: String {
        get { name }
        set { name = newValue }
    }
    
    /// Layout helpers for CanvasRenderer
    var frameSize: CGSize {
        let headerHeight = Constants.Node.headerHeight
        let fieldHeight = Constants.Node.fieldHeight
        let totalHeight = headerHeight + CGFloat(fields.count) * fieldHeight + Constants.Node.padding
        return CGSize(width: Constants.Node.width, height: totalHeight)
    }
    
    var frame: CGRect {
        CGRect(origin: position, size: frameSize)
    }
}

enum NodeColor: String, CaseIterable, Codable, Equatable {
    case blue, green, orange, purple, red, gray
    
    var color: Color {
        switch self {
        case .blue:   return .blue
        case .green:  return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red:    return .red
        case .gray:   return .gray
        }
    }
}
