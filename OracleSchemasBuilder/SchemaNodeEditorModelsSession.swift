//
//  Session.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation

@Observable
class Session: Codable {
    var id: UUID
    var name: String
    var createdDate: Date
    var modifiedDate: Date
    var nodes: [SchemaNode]
    var connections: [Connection]
    var canvasOffset: CGPoint
    var canvasScale: Double
    
    init(
        id: UUID = UUID(),
        name: String = "Untitled Schema",
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        nodes: [SchemaNode] = [],
        connections: [Connection] = [],
        canvasOffset: CGPoint = .zero,
        canvasScale: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.nodes = nodes
        self.connections = connections
        self.canvasOffset = canvasOffset
        self.canvasScale = canvasScale
    }
    
    // MARK: - Compatibility aliases used throughout the UI
    
    /// The UI (ContentView, ExportView, SessionManager) expects `modifiedAt`
    var modifiedAt: Date {
        get { modifiedDate }
        set { modifiedDate = newValue }
    }
    
    /// The UI uses `canvasZoom`; map it to `canvasScale`
    var canvasZoom: Double {
        get { canvasScale }
        set { canvasScale = newValue }
    }
    
    /// Convenience counts for the inspector & sidebar
    var tableCount: Int { nodes.count }
    var fieldCount: Int { nodes.reduce(0) { $0 + $0.fields.count } }
    var relationshipCount: Int { connections.count }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, createdDate, modifiedDate
        case nodes, connections, canvasOffset, canvasScale
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
        nodes = try container.decode([SchemaNode].self, forKey: .nodes)
        connections = try container.decode([Connection].self, forKey: .connections)
        
        let offsetArray = try container.decode([CGFloat].self, forKey: .canvasOffset)
        canvasOffset = CGPoint(x: offsetArray[0], y: offsetArray[1])
        
        canvasScale = try container.decode(Double.self, forKey: .canvasScale)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(connections, forKey: .connections)
        try container.encode([canvasOffset.x, canvasOffset.y], forKey: .canvasOffset)
        try container.encode(canvasScale, forKey: .canvasScale)
    }
    
    func node(with id: UUID) -> SchemaNode? {
        nodes.first { $0.id == id }
    }
    
    func connection(from sourceId: UUID, to targetId: UUID) -> Connection? {
        connections.first { $0.sourceNodeId == sourceId && $0.targetNodeId == targetId }
    }
}
