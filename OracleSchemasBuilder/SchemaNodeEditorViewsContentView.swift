//
//  ContentView.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var selectedNode: SchemaNode?
    @State private var showInspector = true
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedNode) {
                Section("Tables") {
                    ForEach(sessionManager.currentSession.nodes.filter { $0.nodeType == .table }) { node in
                        Label(node.name, systemImage: "tablecells")
                            .tag(node as SchemaNode?)
                    }
                }
                
                Section("Views") {
                    ForEach(sessionManager.currentSession.nodes.filter { $0.nodeType == .view }) { node in
                        Label(node.name, systemImage: "eye")
                            .tag(node as SchemaNode?)
                    }
                }
                
                Section("Other") {
                    ForEach(sessionManager.currentSession.nodes.filter { 
                        $0.nodeType != .table && $0.nodeType != .view 
                    }) { node in
                        Label(node.name, systemImage: iconForNodeType(node.nodeType))
                            .tag(node as SchemaNode?)
                    }
                }
            }
            .navigationTitle(sessionManager.currentSession.name)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        sessionManager.addTableNode()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            // Main canvas area
            CanvasView(selectedNode: $selectedNode)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: { showInspector.toggle() }) {
                            Image(systemName: "sidebar.right")
                        }
                    }
                }
        }
        .inspector(isPresented: $showInspector) {
            InspectorView(selectedNode: $selectedNode)
                .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
        }
    }
    
    private func iconForNodeType(_ type: NodeType) -> String {
        switch type {
        case .table: return "tablecells"
        case .view: return "eye"
        case .procedure: return "function"
        case .function: return "fx"
        case .sequence: return "number"
        case .package: return "shippingbox"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
}
