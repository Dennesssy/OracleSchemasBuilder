import SwiftUI
import Combine // Required to resolve the @EnvironmentObject initialization error

struct NodeView: View {
    let node: SchemaNode
    @EnvironmentObject private var sessionManager: SessionManager
    
    var isSelected: Bool {
        sessionManager.selectedNodeId == node.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: node.type == .table ? "tablecells" : "eye")
                    .foregroundStyle(.white)
                Text(node.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(12)
            .background(node.color.color)
            
            VStack(alignment: .leading, spacing: 8) {
                if node.fields.isEmpty {
                    Text("No fields").font(.caption).foregroundStyle(.secondary).padding(8)
                } else {
                    ForEach(node.fields) { field in
                        HStack {
                            Text(field.name)
                            Spacer()
                            Text(field.dataType).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: SchemaEditorConstants.Node.width)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: SchemaEditorConstants.Node.cornerRadius))
        .shadow(radius: isSelected ? 8 : 4)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: SchemaEditorConstants.Node.cornerRadius)
                    .stroke(Color.accentColor, lineWidth: 2)
            }
        }
        .position(node.position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    sessionManager.moveNode(node.id, to: value.location)
                }
        )
        .onTapGesture {
            sessionManager.selectNode(node.id)
        }
    }
}
