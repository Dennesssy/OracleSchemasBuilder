//
//  Extensions.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation
import CoreGraphics

// MARK: - CGPoint Extensions

extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}

// MARK: - String Extensions

extension String {
    var toSnakeCase: String {
        return self
            .replacingOccurrences(of: " ", with: "_")
            .lowercased()
    }
    
    var toUpperSnakeCase: String {
        return self
            .replacingOccurrences(of: " ", with: "_")
            .uppercased()
    }
}

// MARK: - Array Extensions

// TODO: Uncomment once Field type is defined with isPrimaryKey and isForeignKey properties
#if false
extension Array where Element == Field {
    var primaryKeys: [Field] {
        filter { $0.isPrimaryKey }
    }
    
    var foreignKeys: [Field] {
        filter { $0.isForeignKey }
    }
}
#endif
