//
//  MarkdownExporter.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation

struct MarkdownExporter {
    
    func exportSession(_ session: Session) -> String {
        var markdown = """
        # \(session.name)
        
        **Created:** \(formatDate(session.createdAt))
        **Last Modified:** \(formatDate(session.modifiedAt))
        
        ## Statistics
        
        - **Tables:** \(session.tableCount)
        - **Fields:** \(session.fieldCount)
        - **Relationships:** \(session.relationshipCount)
        
        ---
        
        ## Tables
        
        """
        
        for node in session.nodes.sorted(by: { $0.name < $1.name }) {
            markdown += exportNode(node, connections: session.connections)
            markdown += "\n---\n\n"
        }
        
        markdown += """
        ## Relationships
        
        """
        
        for connection in session.connections {
            markdown += exportConnection(connection, session: session)
            markdown += "\n"
        }
        
        return markdown
    }
    
    func exportOracleSQL(_ session: Session) -> String {
        var sql = """
        -- Schema: \(session.name)
        -- Generated: \(formatDate(Date()))
        --
        -- Tables: \(session.tableCount)
        -- Relationships: \(session.relationshipCount)
        
        """
        
        // Create tables
        for node in session.nodes {
            sql += exportTableSQL(node)
            sql += "\n\n"
        }
        
        // Create foreign keys
        for connection in session.connections {
            sql += exportForeignKeySQL(connection, session: session)
            sql += "\n"
        }
        
        return sql
    }
    
    // MARK: - Private Helpers
    
    private func exportNode(_ node: SchemaNode, connections: [Connection]) -> String {
        var markdown = """
        ### \(node.name)
        
        **Table Name:** `\(node.tableName.isEmpty ? node.name.uppercased() : node.tableName)`
        
        """
        
        if !node.notes.isEmpty {
            markdown += """
            **Notes:** \(node.notes)
            
            """
        }
        
        markdown += """
        #### Fields
        
        | Field Name | Data Type | Constraints |
        |------------|-----------|-------------|
        
        """
        
        for field in node.fields {
            let constraints = field.constraints.joined(separator: ", ")
            markdown += "| `\(field.name)` | \(field.dataType) | \(constraints) |\n"
        }
        
        return markdown
    }
    
    private func exportConnection(_ connection: Connection, session: Session) -> String {
        let sourceNode = session.nodes.first { $0.id == connection.sourceNodeId }
        let targetNode = session.nodes.first { $0.id == connection.targetNodeId }
        
        guard let source = sourceNode, let target = targetNode else {
            return ""
        }
        
        return "- **\(source.name)** → **\(target.name)** (\(connection.relationshipType.rawValue))"
    }
    
    private func exportTableSQL(_ node: SchemaNode) -> String {
        let tableName = node.tableName.isEmpty ? node.name.uppercased().replacingOccurrences(of: " ", with: "_") : node.tableName
        
        var sql = "CREATE TABLE \(tableName) (\n"
        
        // Add fields
        let fieldDefinitions = node.fields.map { field in
            "    \(field.oracleDefinition)"
        }
        
        sql += fieldDefinitions.joined(separator: ",\n")
        
        // Add primary key constraint
        let primaryKeys = node.fields.filter { $0.isPrimaryKey }.map { $0.name }
        if !primaryKeys.isEmpty {
            sql += ",\n    CONSTRAINT pk_\(tableName.lowercased()) PRIMARY KEY (\(primaryKeys.joined(separator: ", ")))"
        }
        
        sql += "\n);"
        
        // Add comments
        if !node.notes.isEmpty {
            sql += "\n\nCOMMENT ON TABLE \(tableName) IS '\(node.notes)';"
        }
        
        for field in node.fields where !field.comment.isEmpty {
            sql += "\nCOMMENT ON COLUMN \(tableName).\(field.name) IS '\(field.comment)';"
        }
        
        return sql
    }
    
    private func exportForeignKeySQL(_ connection: Connection, session: Session) -> String {
        guard let sourceNode = session.nodes.first(where: { $0.id == connection.sourceNodeId }),
              let targetNode = session.nodes.first(where: { $0.id == connection.targetNodeId }),
              let sourceField = sourceNode.fields.first(where: { $0.id == connection.sourceFieldId }),
              let targetField = targetNode.fields.first(where: { $0.id == connection.targetFieldId }) else {
            return ""
        }
        
        let sourceTable = sourceNode.tableName.isEmpty ? sourceNode.name.uppercased().replacingOccurrences(of: " ", with: "_") : sourceNode.tableName
        let targetTable = targetNode.tableName.isEmpty ? targetNode.name.uppercased().replacingOccurrences(of: " ", with: "_") : targetNode.tableName
        
        var sql = """
        ALTER TABLE \(sourceTable)
            ADD CONSTRAINT fk_\(sourceTable.lowercased())_\(targetTable.lowercased())
            FOREIGN KEY (\(sourceField.name))
            REFERENCES \(targetTable) (\(targetField.name))
        """
        
        if connection.onDelete != .noAction {
            sql += "\n    ON DELETE \(connection.onDelete.rawValue)"
        }
        
        sql += ";"
        
        return sql
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
