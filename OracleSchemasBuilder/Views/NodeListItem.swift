import SwiftUI

/// A lightweight row view for the sidebar node list.
struct NodeListItem: View {
    let node: SchemaNode
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        HStack {
            Circle()
                .fill(node.color.color)
                .frame(width: 12, height: 12)
            Text(node.name)
                .foregroundStyle(.primary)
            Spacer()
            if sessionManager.selectedNodeId == node.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(.accent)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            sessionManager.selectNode(node.id)
        }
    }
}
