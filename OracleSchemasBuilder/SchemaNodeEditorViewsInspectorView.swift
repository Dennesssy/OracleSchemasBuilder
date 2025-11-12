//
//  InspectorView.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import SwiftUI

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

struct SessionInspector: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        Form {
            Section("Session") {
                TextField("Name", text: Binding(
                    get: { sessionManager.currentSession.name },
                    set: { sessionManager.currentSession.name = $0 }
                ))
                
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

struct FieldInspectorRow: View {
    let field: TableField
    let onUpdate: (TableField) -> Void
    let onDelete: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Field Name", text: Binding(
                    get: { field.name },
                    set: { newName in
                        var updated = field
                        updated.name = newName
                        onUpdate(updated)
                    }
                ))
                
                TextField("Data Type", text: Binding(
                    get: { field.dataType },
                    set: { newType in
                        var updated = field
                        updated.fieldType = FieldType(rawValue: newType) ?? .varchar2
                        onUpdate(updated)
                    }
                ))
                
                Toggle("Primary Key", isOn: Binding(
                    get: { field.isPrimaryKey },
                    set: { newValue in
                        var updated = field
                        updated.isPrimaryKey = newValue
                        onUpdate(updated)
                    }
                ))
                
                Toggle("Foreign Key", isOn: Binding(
                    get: { field.isForeignKey },
                    set: { newValue in
                        var updated = field
                        updated.isForeignKey = newValue
                        onUpdate(updated)
                    }
                ))
                
                Toggle("Not Null", isOn: Binding(
                    get: { field.isNotNull },
                    set: { newValue in
                        var updated = field
                        updated.isNullable = !newValue
                        onUpdate(updated)
                    }
                ))
                
                Toggle("Unique", isOn: Binding(
                    get: { field.isUnique },
                    set: { newValue in
                        // Unique is not persisted; ignore or handle as needed
                    }
                ))
                
                Button("Delete Field", role: .destructive) {
                    onDelete()
                }
            }
            .padding(.vertical, 8)
        } label: {
            HStack {
                if field.isPrimaryKey {
                    Image(systemName: "key.fill")
                        .foregroundStyle(.yellow)
                } else if field.isForeignKey {
                    Image(systemName: "link")
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(field.name.isEmpty ? "Unnamed Field" : field.name)
                        .font(.body)
                    Text(field.dataType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct AddFieldSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (TableField) -> Void
    
    @State private var name = ""
    @State private var dataType = "VARCHAR2(255)"
    @State private var isPrimaryKey = false
    @State private var isForeignKey = false
    @State private var isNotNull = false
    @State private var isUnique = false
    @State private var defaultValue = ""
    @State private var comment = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Field Information") {
                    TextField("Field Name", text: $name)
                    TextField("Data Type", text: $dataType)
                }
                
                Section("Constraints") {
                    Toggle("Primary Key", isOn: $isPrimaryKey)
                    Toggle("Foreign Key", isOn: $isForeignKey)
                    Toggle("Not Null", isOn: $isNotNull)
                    Toggle("Unique", isOn: $isUnique)
                }
                
                Section("Additional") {
                    TextField("Default Value", text: $defaultValue)
                    TextField("Comment", text: $comment)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add Field")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let field = TableField(
                            name: name,
                            fieldType: .varchar2,
                            length: 255,
                            isPrimaryKey: isPrimaryKey,
                            isForeignKey: isForeignKey,
                            isNullable: !isNotNull,
                            comment: comment
                        )
                        onAdd(field)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

#Preview {
    InspectorView()
        .environmentObject(SessionManager())
}
