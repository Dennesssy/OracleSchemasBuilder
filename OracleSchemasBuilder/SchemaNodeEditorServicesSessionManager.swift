//
//  SessionManager.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation
import SwiftUI

@MainActor
class SessionManager: ObservableObject {
    @Published var currentSession: Session
    @Published var selectedNodeId: UUID?
    @Published var selectedConnectionId: UUID?
    @Published var isDirty: Bool = false
    
    private let storage: SchemaStorage
    
    init(storage: SchemaStorage = SchemaStorage()) {
        self.storage = storage
        self.currentSession = Session()
    }
    
    // MARK: - Node Management
    
    func addNode(at position: CGPoint? = nil) {
        let newPosition = position ?? CGPoint(
            x: Double.random(in: 100...500),
            y: Double.random(in: 100...500)
        )
        
        let node = SchemaNode(position: newPosition)
        currentSession.nodes.append(node)
        selectedNodeId = node.id
        markDirty()
    }
    
    func updateNode(_ node: SchemaNode) {
        if let index = currentSession.nodes.firstIndex(where: { $0.id == node.id }) {
            currentSession.nodes[index] = node
            markDirty()
        }
    }
    
    func deleteNode(_ nodeId: UUID) {
        currentSession.nodes.removeAll { $0.id == nodeId }
        currentSession.connections.removeAll { 
            $0.sourceNodeId == nodeId || $0.targetNodeId == nodeId 
        }
        if selectedNodeId == nodeId {
            selectedNodeId = nil
        }
        markDirty()
    }
    
    func moveNode(_ nodeId: UUID, to position: CGPoint) {
        if let index = currentSession.nodes.firstIndex(where: { $0.id == nodeId }) {
            currentSession.nodes[index].position = position
            markDirty()
        }
    }
    
    // MARK: - Connection Management
    
    func addConnection(_ connection: Connection) {
        currentSession.connections.append(connection)
        markDirty()
    }
    
    func deleteConnection(_ connectionId: UUID) {
        currentSession.connections.removeAll { $0.id == connectionId }
        if selectedConnectionId == connectionId {
            selectedConnectionId = nil
        }
        markDirty()
    }
    
    // MARK: - Session Management
    
    func newSession() {
        currentSession = Session()
        selectedNodeId = nil
        selectedConnectionId = nil
        isDirty = false
    }
    
    func saveSession() {
        currentSession.modifiedAt = Date()
        storage.save(session: currentSession)
        isDirty = false
    }
    
    func loadSession(_ session: Session) {
        currentSession = session
        selectedNodeId = nil
        selectedConnectionId = nil
        isDirty = false
    }
    
    // MARK: - Canvas Management
    
    func updateCanvasOffset(_ offset: CGPoint) {
        currentSession.canvasOffset = offset
    }
    
    func updateCanvasZoom(_ zoom: Double) {
        currentSession.canvasZoom = zoom
    }
    
    // MARK: - Selection
    
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
        selectedConnectionId = nil
    }
    
    func selectConnection(_ connectionId: UUID?) {
        selectedConnectionId = connectionId
        selectedNodeId = nil
    }
    
    // MARK: - Helpers
    
    private func markDirty() {
        isDirty = true
        currentSession.modifiedAt = Date()
    }
    
    func node(for id: UUID) -> SchemaNode? {
        currentSession.nodes.first { $0.id == id }
    }
}
