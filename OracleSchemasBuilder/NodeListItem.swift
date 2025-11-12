import SwiftUI

/// Simple list item used in the sidebar of `ContentView`.
struct NodeListItem: View {
    let node: SchemaNode
    
    var body: some View {
        Label(node.name, systemImage: "tablecells")
            .accessibilityIdentifier("nodeListItem_\(node.id.uuidString)")
    }
}
