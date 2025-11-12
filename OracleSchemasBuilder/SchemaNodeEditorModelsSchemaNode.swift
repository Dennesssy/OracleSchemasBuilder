//
//  SchemaNode.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation
import SwiftUI

enum NodeType: String, Codable, CaseIterable {
    case table
    case view
    case procedure
    case function
    case sequence
    case package
}

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
    
    // For connections
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
        
        let x = try container.decode(CGFloat.self, forKey: .position)
        let y = try container.decode([CGFloat].self, forKey: .position)
        position = CGPoint(x: x, y: y[1])
        
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
}

struct NodeColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    static let blue = NodeColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    static let green = NodeColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1.0)
    static let orange = NodeColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    static let purple = NodeColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
    static let red = NodeColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
