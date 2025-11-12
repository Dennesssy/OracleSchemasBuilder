import Foundation
import SwiftUI

@MainActor
class SessionManager: ObservableObject {
    @Published var currentSession: Session = Session()
    @Published var selectedNodeId: UUID?
    @Published var selectedConnectionId: UUID?
    @Published var isDirty: Bool = false
    
    private let storage: SchemaStorage
    
    /// Undo manager supplied by the UI
    var undoManager: UndoManager?
    
    init(storage: SchemaStorage = SchemaStorage()) {
        self.storage = storage
        self.currentSession = Session()
    }
    
    /// Called by the view to inject the environment undo manager
    func setUndoManager(_ manager: UndoManager?) {
        self.undoManager = manager
    }
    
    // MARK: - Node Management
    
    func addNode(at position: CGPoint? = nil) {
        let newPosition = position ?? CGPoint(
            x: Double.random(in: 100...500),
            y: Double.random(in: 100...500)
        )
        
        let node = SchemaNode(
            name: "NewTable",
            nodeType: .table,
            position: newPosition,
            fields: [],
            notes: "",
            schema: "PUBLIC",
            color: .blue,
            outgoingConnections: []
        )
        currentSession.nodes.append(node)
        selectedNodeId = node.id
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deleteNode(node.id)
        }
        undoManager?.setActionName("Add Node")
    }
    
    func addNode(_ node: SchemaNode) {
        currentSession.nodes.append(node)
        selectedNodeId = node.id
        markDirty()
    }
    
    func updateNode(_ node: SchemaNode) {
        guard let index = currentSession.nodes.firstIndex(where: { $0.id == node.id }) else { return }
        let oldNode = currentSession.nodes[index]
        currentSession.nodes[index] = node
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.updateNode(oldNode)
        }
        undoManager?.setActionName("Edit Node")
    }
    
    func deleteNode(_ nodeId: UUID) {
        guard let node = currentSession.nodes.first(where: { $0.id == nodeId }) else { return }
        currentSession.nodes.removeAll { $0.id == nodeId }
        currentSession.connections.removeAll { $0.sourceNodeId == nodeId || $0.targetNodeId == nodeId }
        if selectedNodeId == nodeId { selectedNodeId = nil }
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.readdNode(node)
        }
        undoManager?.setActionName("Delete Node")
    }
    
    private func readdNode(_ node: SchemaNode) {
        currentSession.nodes.append(node)
        markDirty()
    }
    
    func moveNode(_ nodeId: UUID, to position: CGPoint) {
        guard let index = currentSession.nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        let oldPosition = currentSession.nodes[index].position
        currentSession.nodes[index].position = position
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.moveNode(nodeId, to: oldPosition)
        }
        undoManager?.setActionName("Move Node")
    }
    
    // MARK: - Connection Management
    
    func addConnection(_ connection: Connection) {
        currentSession.connections.append(connection)
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deleteConnection(connection.id)
        }
        undoManager?.setActionName("Add Connection")
    }
    
    func deleteConnection(_ connectionId: UUID) {
        guard let connection = currentSession.connections.first(where: { $0.id == connectionId }) else { return }
        currentSession.connections.removeAll { $0.id == connectionId }
        if selectedConnectionId == connectionId { selectedConnectionId = nil }
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.readdConnection(connection)
        }
        undoManager?.setActionName("Delete Connection")
    }
    
    private func readdConnection(_ connection: Connection) {
        currentSession.connections.append(connection)
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
    
    // Helper methods used by the canvas context menu
    func addTableNode(at position: CGPoint) { addNode(at: position) }
    func addViewNode(at position: CGPoint) {
        let node = SchemaNode(
            name: "NewView",
            nodeType: .view,
            position: position,
            fields: [],
            notes: "",
            schema: "PUBLIC",
            color: .green,
            outgoingConnections: []
        )
        currentSession.nodes.append(node)
        selectedNodeId = node.id
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deleteNode(node.id)
        }
        undoManager?.setActionName("Add View Node")
    }
}
