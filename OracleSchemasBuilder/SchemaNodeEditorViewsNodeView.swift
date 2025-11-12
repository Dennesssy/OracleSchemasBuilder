import SwiftUI

#if false
struct NodeView: View {
    let node: SchemaNode
    @EnvironmentObject var sessionManager: SessionManager
    
    var isSelected: Bool {
        sessionManager.selectedNodeId == node.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "tablecells")
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("nodeHeaderImage")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(node.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Menu {
                    Button("Edit") {
                        sessionManager.selectNode(node.id)
                    }
                    
                    Divider()
                    
                    Button("Delete", role: .destructive) {
                        sessionManager.deleteNode(node.id)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(12)
            .background(colorForNode(node.color))
            
            // Fields
            VStack(alignment: .leading, spacing: 8) {
                if node.fields.isEmpty {
                    Text("No fields")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(8)
                } else {
                    ForEach(node.fields) { field in
                        FieldRow(field: field)
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: Constants.Node.width)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: isSelected ? .accentColor.opacity(0.4) : .black.opacity(0.2), radius: isSelected ? 8 : 4)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 2)
            }
        }
        .offset(x: node.position.x, y: node.position.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    sessionManager.moveNode(node.id, to: CGPoint(
                        x: node.position.x + value.translation.width,
                        y: node.position.y + value.translation.height
                    ))
                }
        )
        .onTapGesture {
            sessionManager.selectNode(node.id)
        }
        .accessibilityLabel("Node \(node.name)")
    }
    
    private func colorForNode(_ color: NodeColor) -> Color { color.color }
}
#endif
