//
//  SessionManager.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 11/12/25.
//

import Foundation
import SwiftUI

/// Manages the current schema design session, including undo/redo support.
@Observable
class SessionManager {
    var currentSession: Session
    var isDirty: Bool = false
    var undoManager: UndoManager?
    var selectedNodeId: UUID?
    
    init() {
        self.currentSession = Session()
    }
    
    // MARK: - Undo Manager
    
    func setUndoManager(_ undoManager: UndoManager?) {
        self.undoManager = undoManager
    }
    
    // MARK: - Session Management
    
    func newSession() {
        currentSession = Session()
        isDirty = false
    }
    
    func saveSession() {
        // TODO: Implement actual persistence logic
        currentSession.modifiedDate = Date()
        isDirty = false
        print("Session saved: \(currentSession.name)")
    }
    
    // MARK: - Node Management
    
    func addNode() {
        let newNode = SchemaNode(
            id: UUID(),
            name: "Table_\(currentSession.nodes.count + 1)",
            position: CGPoint(x: 100, y: 100),
            fields: []
        )
        currentSession.nodes.append(newNode)
        markDirty()
    }
    
    func addTableNode(at position: CGPoint = CGPoint(x: 100, y: 100)) {
        let newNode = SchemaNode(
            id: UUID(),
            name: "Table_\(currentSession.nodes.count + 1)",
            position: position,
            fields: []
        )
        currentSession.nodes.append(newNode)
        markDirty()
    }
    
    func addViewNode(at position: CGPoint = CGPoint(x: 100, y: 100)) {
        let newNode = SchemaNode(
            id: UUID(),
            name: "View_\(currentSession.nodes.count + 1)",
            position: position,
            fields: []
        )
        currentSession.nodes.append(newNode)
        markDirty()
    }
    
    func selectNode(_ nodeId: UUID) {
        selectedNodeId = nodeId
        print("Selected node: \(nodeId)")
    }
    
    func removeNode(_ nodeId: UUID) {
        currentSession.nodes.removeAll { $0.id == nodeId }
        // Also remove any connections to/from this node
        currentSession.connections.removeAll { 
            $0.sourceNodeId == nodeId || $0.targetNodeId == nodeId 
        }
        markDirty()
    }
    
    // MARK: - Export
    
    func exportAsMarkdown() {
        // TODO: Implement markdown export
        print("Exporting as Markdown...")
    }
    
    // MARK: - Helpers
    
    private func markDirty() {
        isDirty = true
        currentSession.modifiedDate = Date()
    }
}
