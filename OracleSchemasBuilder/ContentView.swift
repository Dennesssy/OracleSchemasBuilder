import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.undoManager) var undoManager
    @State private var showingInspector = true
    @State private var showingExport = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                // Session info
                VStack(alignment: .leading, spacing: 8) {
                    Text(sessionManager.currentSession.name)
                        .font(.headline)
                    
                    Text("\(sessionManager.currentSession.tableCount) tables")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                // Actions
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        sessionManager.addNode()
                    } label: {
                        Label("Add Table", systemImage: "plus.circle")
                    }
                    
                    Button {
                        showingExport = true
                    } label: {
                        Label("Export Schema", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        sessionManager.saveSession()
                    } label: {
                        Label("Save", systemImage: "folder")
                    }
                    .disabled(!sessionManager.isDirty)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Node list
                List(sessionManager.currentSession.nodes, selection: $sessionManager.selectedNodeId) { node in
                    NodeListItem(node: node)
                }
                .listStyle(.sidebar)
                
                Spacer()
            }
            .frame(minWidth: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        sessionManager.newSession()
                    } label: {
                        Image(systemName: "doc.badge.plus")
                    }
                }
            }
        } detail: {
            // Main canvas area
            ZStack {
                CanvasView(selectedNodeId: $sessionManager.selectedNodeId)
                
                if sessionManager.currentSession.nodes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tablecells")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("No Tables Yet")
                            .font(.title2)
                        
                        Text("Click 'Add Table' to create your first table")
                            .foregroundStyle(.secondary)
                        
                        Button("Add Table") {
                            sessionManager.addNode()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
            }
            .inspector(isPresented: $showingInspector) {
                InspectorView()
                    .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
            }
            .sheet(isPresented: $showingExport) {
                ExportView()
            }
        }
        .onAppear {
            // Provide the UndoManager to SessionManager
            sessionManager.setUndoManager(undoManager)
        }
    }
}

struct NodeListItem: View {
    let node: SchemaNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(node.name)
                .font(.body)
            
            Text("\(node.fields.count) fields")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
}
