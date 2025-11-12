//
//  TableField.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation

enum FieldType: String, Codable, CaseIterable {
    case varchar2 = "VARCHAR2"
    case number = "NUMBER"
    case date = "DATE"
    case timestamp = "TIMESTAMP"
    case clob = "CLOB"
    case blob = "BLOB"
    case char = "CHAR"
    case integer = "INTEGER"
    case float = "FLOAT"
    case raw = "RAW"
}

@Observable
class TableField: Identifiable, Codable {
    let id: UUID
    var name: String
    var fieldType: FieldType
    var length: Int?
    var precision: Int?
    var scale: Int?
    var isNullable: Bool
    var isPrimaryKey: Bool
    var isForeignKey: Bool
    var defaultValue: String?
    var comment: String
    
    // Foreign key reference
    var referencedTable: String?
    var referencedField: String?
    
    init(
        id: UUID = UUID(),
        name: String = "field_name",
        fieldType: FieldType = .varchar2,
        length: Int? = 255,
        precision: Int? = nil,
        scale: Int? = nil,
        isNullable: Bool = true,
        isPrimaryKey: Bool = false,
        isForeignKey: Bool = false,
        defaultValue: String? = nil,
        comment: String = "",
        referencedTable: String? = nil,
        referencedField: String? = nil
    ) {
        self.id = id
        self.name = name
        self.fieldType = fieldType
        self.length = length
        self.precision = precision
        self.scale = scale
        self.isNullable = isNullable
        self.isPrimaryKey = isPrimaryKey
        self.isForeignKey = isForeignKey
        self.defaultValue = defaultValue
        self.comment = comment
        self.referencedTable = referencedTable
        self.referencedField = referencedField
    }
    
    // MARK: - UI‑friendly aliases
    var dataType: String { typeDescription }
    var isNotNull: Bool { !isNullable }
    var isUnique: Bool { false }
    
    var typeDescription: String {
        switch fieldType {
        case .varchar2, .char:
            if let length = length {
                return "\(fieldType.rawValue)(\(length))"
            }
        case .number:
            if let precision = precision {
                if let scale = scale {
                    return "NUMBER(\(precision),\(scale))"
                }
                return "NUMBER(\(precision))"
            }
        default:
            break
        }
        return fieldType.rawValue
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, fieldType, length, precision, scale
        case isNullable, isPrimaryKey, isForeignKey
        case defaultValue, comment, referencedTable, referencedField
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fieldType = try container.decode(FieldType.self, forKey: .fieldType)
        length = try container.decodeIfPresent(Int.self, forKey: .length)
        precision = try container.decodeIfPresent(Int.self, forKey: .precision)
        scale = try container.decodeIfPresent(Int.self, forKey: .scale)
        isNullable = try container.decode(Bool.self, forKey: .isNullable)
        isPrimaryKey = try container.decode(Bool.self, forKey: .isPrimaryKey)
        isForeignKey = try container.decode(Bool.self, forKey: .isForeignKey)
        defaultValue = try container.decodeIfPresent(String.self, forKey: .defaultValue)
        comment = try container.decode(String.self, forKey: .comment)
        referencedTable = try container.decodeIfPresent(String.self, forKey: .referencedTable)
        referencedField = try container.decodeIfPresent(String.self, forKey: .referencedField)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fieldType, forKey: .fieldType)
        try container.encodeIfPresent(length, forKey: .length)
        try container.encodeIfPresent(precision, forKey: .precision)
        try container.encodeIfPresent(scale, forKey: .scale)
        try container.encode(isNullable, forKey: .isNullable)
        try container.encode(isPrimaryKey, forKey: .isPrimaryKey)
        try container.encode(isForeignKey, forKey: .isForeignKey)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encode(comment, forKey: .comment)
        try container.encodeIfPresent(referencedTable, forKey: .referencedTable)
        try container.encodeIfPresent(referencedField, forKey: .referencedField)
    }
}
