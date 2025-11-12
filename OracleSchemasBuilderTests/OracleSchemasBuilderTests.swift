import Testing
@testable import OracleSchemasBuilder

enum TestError: Error {
    static let nodeNotFound = TestError()
}

struct OracleSchemasBuilderTests {
    
    @Test func addNode_createsDefaultTableNode_and_canUndo() async throws {
        // Arrange
        let manager = SessionManager()
        let undo = UndoManager()
        manager.setUndoManager(undo)
        
        #expect(manager.currentSession.nodes.isEmpty)
        #expect(!manager.isDirty)
        
        // Act
        manager.addNode()
        
        // Assert – node added
        #expect(manager.currentSession.nodes.count == 1)
        guard let node = manager.currentSession.nodes.first else {
            throw TestError.nodeNotFound
        }
        #expect(node.name == "NewTable")
        #expect(node.nodeType == .table)
        #expect(manager.isDirty)
        #expect(manager.currentSession.modifiedAt.timeIntervalSinceNow <= 0)
        
        // Undo the addition
        undo.undo()
        
        // Node should be removed
        #expect(manager.currentSession.nodes.isEmpty)
    }
}
