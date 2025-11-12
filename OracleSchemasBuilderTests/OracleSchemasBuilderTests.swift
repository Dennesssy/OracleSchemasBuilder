import Testing
@testable import OracleSchemasBuilder

struct OracleSchemasBuilderTests {

    @Test func addNode_createsDefaultTableNode() async throws {
        // Arrange
        let manager = SessionManager()
        #expect(manager.currentSession.nodes.isEmpty)          // session starts empty
        #expect(!manager.isDirty)                             // session not dirty yet

        // Act
        manager.addNode()

        // Assert – node added
        #expect(manager.currentSession.nodes.count == 1)
        let node = try #require(manager.currentSession.nodes.first)

        #expect(node.name == "NewTable")
        #expect(node.nodeType == .table)

        // Assert – session marked dirty and modified date updated
        #expect(manager.isDirty)
        #expect(manager.currentSession.modifiedAt.timeIntervalSinceNow <= 0,
                "modifiedAt should be set to a recent date")
    }
}
