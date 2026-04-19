import Foundation
import SwiftUI
import Combine

/// Manages the current schema design session.
final class SessionManager: ObservableObject {
    @Published var currentSession: Session
    @Published var isDirty: Bool = false
    @Published var selectedNodeId: UUID?
    
    private var undoManager: UndoManager?
    
    init() {
        // Initialize with a default Session object
        self.currentSession = Session(
            id: UUID(),
            name: "Untitled Session",
            createdDate: Date(),
            modifiedDate: Date(),
            nodes: [],
            connections: []
        )
    }
    
    func setUndoManager(_ undoManager: UndoManager?) {
        self.undoManager = undoManager
    }
    
    func newSession() {
        currentSession = Session()
        isDirty = false
    }
    
    func addNode() {
        addTableNode()
    }
    
    func addTableNode(at position: CGPoint = CGPoint(x: 100, y: 100)) {
        let newNode = SchemaNode(
            id: UUID(),
            name: "Table_\(currentSession.nodes.count + 1)",
            type: .table,
            position: position
        )
        currentSession.nodes.append(newNode)
        markDirty()
    }
    
    func addViewNode(at position: CGPoint = CGPoint(x: 100, y: 100)) {
        let newNode = SchemaNode(
            id: UUID(),
            name: "View_\(currentSession.nodes.count + 1)",
            type: .view,
            position: position
        )
        currentSession.nodes.append(newNode)
        markDirty()
    }
    
    func moveNode(_ id: UUID, to position: CGPoint) {
        if let index = currentSession.nodes.firstIndex(where: { $0.id == id }) {
            currentSession.nodes[index].position = position
            markDirty()
        }
    }
    
    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
    }
    
    func deleteNode(_ id: UUID) {
        currentSession.nodes.removeAll { $0.id == id }
        currentSession.connections.removeAll { $0.sourceNodeId == id || $0.targetNodeId == id }
        markDirty()
    }
    
    private func markDirty() {
        isDirty = true
        currentSession.modifiedDate = Date()
    }
}
