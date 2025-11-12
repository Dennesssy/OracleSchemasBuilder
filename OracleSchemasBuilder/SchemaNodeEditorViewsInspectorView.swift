import SwiftUI

/// Inspector panel that displays either session info or the selected node’s properties.
struct InspectorView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Group {
            if let selectedNodeId = sessionManager.selectedNodeId,
               let node = sessionManager.node(for: selectedNodeId) {
                NodeInspector(node: node)
            } else {
                SessionInspector()
            }
        }
        .frame(minWidth: 250)
    }
}

/// Displays global session information.
struct SessionInspector: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Form {
            Section("Session") {
                TextField("Name", text: Binding(
                    get: { sessionManager.currentSession.name },
                    set: { sessionManager.currentSession.name = $0 }
                ))
                .accessibilityIdentifier("sessionNameTextField")
                
                LabeledContent("Tables") {
                    Text("\(sessionManager.currentSession.tableCount)")
                }
                
                LabeledContent("Fields") {
                    Text("\(sessionManager.currentSession.fieldCount)")
                }
                
                LabeledContent("Relationships") {
                    Text("\(sessionManager.currentSession.relationshipCount)")
                }
            }
            
            Section("Canvas") {
                LabeledContent("Zoom") {
                    Text(String(format: "%.0f%%", sessionManager.currentSession.canvasZoom * 100))
                }
            }
        }
        .formStyle(.grouped)
    }
}

/// Inspector for a selected node.
struct NodeInspector: View {
    let node: SchemaNode
    @EnvironmentObject var sessionManager: SessionManager
    @State private var editedNode: SchemaNode
    @State private var showingAddField = false
    
    init(node: SchemaNode) {
        self.node = node
        _editedNode = State(initialValue: node)
    }
    
    var body: some View {
        Form {
            Section("Table Information") {
                TextField("Name", text: $editedNode.name)
                    .onChange(of: editedNode.name) { _, _ in
                        updateNode()
                    }
                    .accessibilityIdentifier("nodeNameTextField")
                
                TextField("Table Name", text: $editedNode.tableName)
                    .onChange(of: editedNode.tableName) { _, _ in
                        updateNode()
                    }
                
                Picker("Color", selection: $editedNode.color) {
                    ForEach(NodeColor.allCases, id: \.self) { color in
                        Text(color.rawValue.capitalized)
                            .tag(color)
                    }
                }
                .onChange(of: editedNode.color) { _, _ in
                    updateNode()
                }
            }
            
            Section {
                TextEditor(text: $editedNode.notes)
                    .frame(minHeight: 60)
                    .onChange(of: editedNode.notes) { _, _ in
                        updateNode()
                    }
                    .accessibilityIdentifier("nodeNotesEditor")
            } header: {
                Text("Notes")
            }
            
            Section {
                List {
                    ForEach(editedNode.fields) { field in
                        FieldInspectorRow(field: field) { updatedField in
                            if let index = editedNode.fields.firstIndex(where: { $0.id == field.id }) {
                                editedNode.fields[index] = updatedField
                                updateNode()
                            }
                        } onDelete: {
                            editedNode.fields.removeAll { $0.id == field.id }
                            updateNode()
                        }
                    }
                }
                
                Button {
                    showingAddField = true
                } label: {
                    Label("Add Field", systemImage: "plus.circle")
                }
            } header: {
                Text("Fields")
            }
            
            Section {
                Button("Delete Table", role: .destructive) {
                    sessionManager.deleteNode(node.id)
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingAddField) {
            AddFieldSheet { newField in
                editedNode.fields.append(newField)
                updateNode()
                showingAddField = false
            }
        }
    }
    
    private func updateNode() {
        sessionManager.updateNode(editedNode)
    }
}
...
