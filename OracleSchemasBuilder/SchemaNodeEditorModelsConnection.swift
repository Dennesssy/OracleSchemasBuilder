//
//  Connection.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation
import SwiftUI

enum ConnectionType: String, Codable {
    case oneToOne = "1:1"
    case oneToMany = "1:N"
    case manyToOne = "N:1"
    case manyToMany = "N:M"
}

@Observable
class Connection: Identifiable, Codable {
    let id: UUID
    var sourceNodeId: UUID
    var targetNodeId: UUID
    var sourceFieldId: UUID?
    var targetFieldId: UUID?
    var connectionType: ConnectionType
    var label: String
    
    init(
        id: UUID = UUID(),
        sourceNodeId: UUID,
        targetNodeId: UUID,
        sourceFieldId: UUID? = nil,
        targetFieldId: UUID? = nil,
        connectionType: ConnectionType = .oneToMany,
        label: String = ""
    ) {
        self.id = id
        self.sourceNodeId = sourceNodeId
        self.targetNodeId = targetNodeId
        self.sourceFieldId = sourceFieldId
        self.targetFieldId = targetFieldId
        self.connectionType = connectionType
        self.label = label
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, sourceNodeId, targetNodeId
        case sourceFieldId, targetFieldId
        case connectionType, label
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sourceNodeId = try container.decode(UUID.self, forKey: .sourceNodeId)
        targetNodeId = try container.decode(UUID.self, forKey: .targetNodeId)
        sourceFieldId = try container.decodeIfPresent(UUID.self, forKey: .sourceFieldId)
        targetFieldId = try container.decodeIfPresent(UUID.self, forKey: .targetFieldId)
        connectionType = try container.decode(ConnectionType.self, forKey: .connectionType)
        label = try container.decode(String.self, forKey: .label)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sourceNodeId, forKey: .sourceNodeId)
        try container.encode(targetNodeId, forKey: .targetNodeId)
        try container.encodeIfPresent(sourceFieldId, forKey: .sourceFieldId)
        try container.encodeIfPresent(targetFieldId, forKey: .targetFieldId)
        try container.encode(connectionType, forKey: .connectionType)
        try container.encode(label, forKey: .label)
    }
}
