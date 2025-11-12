//
//  InspectorView.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 11/12/25.
//

import SwiftUI

struct InspectorView: View {
    @Environment(SessionManager.self) private var sessionManager
    @Environment(CanvasState.self) private var canvasState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Session Info
                GroupBox("Session Info") {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Name", value: sessionManager.currentSession.name)
                        InfoRow(label: "Tables", value: "\(sessionManager.currentSession.tableCount)")
                        InfoRow(label: "Fields", value: "\(sessionManager.currentSession.fieldCount)")
                        InfoRow(label: "Relationships", value: "\(sessionManager.currentSession.relationshipCount)")
                    }
                }
                
                // Selected Node Info
                if let selectedId = canvasState.selectedNodeId,
                   let node = sessionManager.currentSession.node(with: selectedId) {
                    GroupBox("Selected Table") {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Name", value: node.name)
                            InfoRow(label: "Fields", value: "\(node.fields.count)")
                            InfoRow(label: "Position", value: "(\(Int(node.position.x)), \(Int(node.position.y)))")
                        }
                    }
                } else {
                    GroupBox("Selection") {
                        Text("No table selected")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    InspectorView()
        .environmentObject(SessionManager())
        .environment(CanvasState())
        .frame(width: 300)
}

