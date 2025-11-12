import SwiftUI

/// Simple placeholder for the sidebar node list item.
/// Replace with a richer view if desired.
struct NodeListItem: View {
    let node: SchemaNode
    
    var body: some View {
        Text(node.name)
            .accessibilityIdentifier("nodeListItem_\(node.id.uuidString)")
    }
}
