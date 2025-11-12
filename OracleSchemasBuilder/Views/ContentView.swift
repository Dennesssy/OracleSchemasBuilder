import SwiftUI

struct ContentView: View {
    // MARK: - Environment & State
    
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.undoManager) var undoManager
    @StateObject private var canvasState = CanvasState()
    
    // UI‑only toggles (template library, settings panel, inspector)
    @State private var showInspector = true
    @State private var showTemplateLibrary = false
    @State private var showSettings = false
    @State private var showExport = false
    
    var body: some View {
        NavigationSplitView {
            // ---------- Sidebar ----------
            VStack(alignment: .leading, spacing: 20) {
                // Session header
                VStack(alignment: .leading, spacing: 8) {
                    Text(sessionManager.currentSession.name)
                        .font(.headline)
                    
                    Text("\(sessionManager.currentSession.tableCount) tables")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                // Primary actions
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        sessionManager.addNode()
                    } label: {
                        Label("Add Table", systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("addTableButton")
                    
                    Button {
                        showTemplateLibrary.toggle()
                    } label: {
                        Label("Templates", systemImage: "doc.text.magnifyingglass")
                    }
                    .accessibilityIdentifier("templateLibraryButton")
                    
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                    
                    Button {
                        showExport.toggle()
                    } label: {
                        Label("Export Schema", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("exportSchemaButton")
                    
                    Button {
                        sessionManager.saveSession()
                    } label: {
                        Label("Save", systemImage: "folder")
                    }
                    .disabled(!sessionManager.isDirty)
                    .accessibilityIdentifier("saveButton")
                }
                .padding(.horizontal)
                
                Divider()
                
                // Node list (uses the *shared* selection from CanvasState)
                List(sessionManager.currentSession.nodes,
                     selection: $canvasState.selectedNodeId) { node in
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
                    .accessibilityIdentifier("newSessionButton")
                }
            }
        } detail: {
            // ---------- Canvas area ----------
            ZStack {
                CanvasView(
                    selectedNodeId: $canvasState.selectedNodeId,
                    offset: $canvasState.offset,
                    scale: $canvasState.scale
                )
                
                // Empty‑canvas hint
                if sessionManager.currentSession.nodes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tablecells")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("No Tables Yet")
                            .font(.title2)
                        
                        Text("Click ‘Add Table’ to create your first table")
                            .foregroundStyle(.secondary)
                        
                        Button("Add Table") {
                            sessionManager.addNode()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .toolbar {
                // Inspector toggle
                ToolbarItem(placement: .automatic) {
                    Button {
                        showInspector.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
                // Reset view (pan/zoom) – uses CanvasState helper
                ToolbarItem(placement: .automatic) {
                    Button {
                        withAnimation {
                            canvasState.resetView()
                        }
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                    }
                    .accessibilityIdentifier("resetViewButton")
                }
            }
            .inspector(isPresented: $showInspector) {
                InspectorView()
                    .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
            }
            .sheet(isPresented: $showExport) {
                ExportView()
            }
            .sheet(isPresented: $showTemplateLibrary) {
                TemplateLibraryView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        // -------------------------------------------------
        // Provide the UndoManager to the SessionManager *once*
        // the view hierarchy is attached to a window.
        // -------------------------------------------------
        .onAppear {
            // `undoManager` comes from the environment of the root view.
            // We forward it to the manager only once (guard against re‑set).
            if sessionManager.undoManager == nil {
                sessionManager.setUndoManager(undoManager)
            }
        }
    }
}
