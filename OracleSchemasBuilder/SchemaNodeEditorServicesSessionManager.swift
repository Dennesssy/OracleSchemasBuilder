import Foundation
import SwiftUI

/// Manages the current schema editing session and provides undo/redo support.
@Observable
class SessionManager {
    /// The session currently being edited.
    var currentSession: Session = Session()
    /// The UUID of the node that is currently selected.
    var selectedNodeId: UUID?
    /// The UUID of the connection that is currently selected.
    var selectedConnectionId: UUID?
    /// Indicates whether the session has unsaved changes.
    var isDirty: Bool = false
    
    private let storage: SchemaStorage
    
    /// Undo manager supplied by the UI.
    var undoManager: UndoManager?
    
    /// Creates a new session manager.
    /// - Parameter storage: The storage service used to persist sessions.
    init(storage: SchemaStorage = SchemaStorage()) {
        self.storage = storage
        self.currentSession = Session()
    }
    
    /// Injects the environment undo manager.
    /// - Parameter manager: The undo manager to use for user actions.
    func setUndoManager(_ manager: UndoManager?) {
        self.undoManager = manager
    }
    
    // MARK: - Node Management
    
    /// Adds a new table node at the specified position or at a random location.
    /// - Parameter position: Optional position for the new node.
    func addNode(at position: CGPoint? = nil) {
        let newPosition = position ?? CGPoint(
            x: Double.random(in: Constants.File.defaultPositionRange),
            y: Double.random(in: Constants.File.defaultPositionRange)
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
    
    /// Adds a node directly (used by external callers).
    /// - Parameter node: The node to add.
    func addNode(_ node: SchemaNode) {
        currentSession.nodes.append(node)
        selectedNodeId = node.id
        markDirty()
    }
    
    /// Updates an existing node with new data.
    /// - Parameter node: The node to update.
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
    
    /// Deletes the node with the given UUID.
    /// - Parameter nodeId: The UUID of the node to delete.
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
    
    /// Moves a node to a new position.
    /// - Parameters:
    ///   - nodeId: The UUID of the node to move.
    ///   - position: The new position.
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
    
    /// Adds a new connection between nodes.
    /// - Parameter connection: The connection to add.
    func addConnection(_ connection: Connection) {
        currentSession.connections.append(connection)
        markDirty()
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deleteConnection(connection.id)
        }
        undoManager?.setActionName("Add Connection")
    }
    
    /// Deletes the connection with the given UUID.
    /// - Parameter connectionId: The UUID of the connection to delete.
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
    
    /// Creates a new, clean session.
    func newSession() {
        currentSession = Session()
        selectedNodeId = nil
        selectedConnectionId = nil
        isDirty = false
    }
    
    /// Persists the current session to disk.
    func saveSession() {
        currentSession.modifiedAt = Date()
        storage.save(session: currentSession)
        isDirty = false
    }
    
    /// Loads a session into memory.
    /// - Parameter session: The session to load.
    func loadSession(_ session: Session) {
        currentSession = session
        selectedNodeId = nil
        selectedConnectionId = nil
        isDirty = false
    }
    
    // MARK: - Canvas Management
    
    /// Updates the canvas offset (panning).
    /// - Parameter offset: The new offset.
    func updateCanvasOffset(_ offset: CGPoint) {
        currentSession.canvasOffset = offset
    }
    
    /// Updates the canvas zoom level.
    /// - Parameter zoom: The new zoom level.
    func updateCanvasZoom(_ zoom: Double) {
        currentSession.canvasZoom = zoom
    }
    
    // MARK: - Selection
    
    /// Selects a node by UUID.
    /// - Parameter nodeId: The UUID of the node to select.
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
        selectedConnectionId = nil
    }
    
    /// Selects a connection by UUID.
    /// - Parameter connectionId: The UUID of the connection to select.
    func selectConnection(_ connectionId: UUID?) {
        selectedConnectionId = connectionId
        selectedNodeId = nil
    }
    
    // MARK: - Helpers
    
    /// Marks the current session as dirty (modified).
    private func markDirty() {
        isDirty = true
        currentSession.modifiedAt = Date()
    }
    
    /// Retrieves a node by UUID.
    /// - Parameter id: The UUID of the node.
    /// - Returns: The node if found, otherwise `nil`.
    func node(for id: UUID) -> SchemaNode? {
        currentSession.nodes.first { $0.id == id }
    }
    
    // MARK: - Convenience Node Creation
    
    /// Adds a table node at a given position (used by context menus).
    /// - Parameter position: The position to place the new table.
    func addTableNode(at position: CGPoint) {
        addNode(at: position)
    }
    
    /// Adds a view node at a given position.
    /// - Parameter position: The position to place the new view.
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
