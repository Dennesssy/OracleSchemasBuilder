import Foundation
import CoreGraphics
import SwiftUI
import Combine // Required for @Published and ObservableObject

final class Session: ObservableObject, Codable, Identifiable {
    @Published var id: UUID
    @Published var name: String
    @Published var createdDate: Date
    @Published var modifiedDate: Date
    @Published var nodes: [SchemaNode]
    @Published var connections: [Connection]
    
    @Published var canvasOffset: CGPoint
    @Published var canvasScale: Double
    
    init(
        id: UUID = UUID(),
        name: String = "Untitled Session",
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
    
    // MARK: - Computed Properties
    var tableCount: Int { nodes.filter { $0.type == .table }.count }
    var fieldCount: Int { nodes.reduce(0) { $0 + $1.fields.count } }
    var relationshipCount: Int { connections.count }
    
    func node(with id: UUID) -> SchemaNode? {
        nodes.first { $0.id == id }
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, createdDate, modifiedDate, nodes, connections, canvasOffset, canvasScale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
        nodes = try container.decode([SchemaNode].self, forKey: .nodes)
        connections = try container.decode([Connection].self, forKey: .connections)
        let offsetArray = try container.decode([CGFloat].self, forKey: .canvasOffset)
        canvasOffset = CGPoint(x: offsetArray.count > 0 ? offsetArray[0] : 0,
                               y: offsetArray.count > 1 ? offsetArray[1] : 0)
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
}
