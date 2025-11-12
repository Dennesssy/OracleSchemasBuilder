import SwiftUI

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
        .frame(width: 300)
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
    }
    
    private func colorForNode(_ color: NodeColor) -> Color { color.color }
}

struct FieldRow: View {
    let field: TableField
    
    var body: some View {
        HStack(spacing: 8) {
            // Key indicator
            if field.isPrimaryKey {
                Image(systemName: "key.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            } else if field.isForeignKey {
                Image(systemName: "link")
                    .font(.caption)
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(field.name)
                    .font(.body)
                
                Text(field.dataType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Constraint badges
            if field.isNotNull {
                Text("NN")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            
            if field.isUnique {
                Text("U")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.purple.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    NodeView(node: SchemaNode.example)
        .environmentObject(SessionManager())
        .frame(width: 400, height: 300)
        .padding()
}
