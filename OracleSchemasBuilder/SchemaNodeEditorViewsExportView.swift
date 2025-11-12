//
//  ExportView.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedFormat: ExportFormat = .sql
    @State private var showingFilePicker = false
    @State private var previewText = ""
    
    enum ExportFormat: String, CaseIterable {
        case sql = "Oracle SQL"
        case markdown = "Markdown"
        case json = "JSON"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Format picker
                Picker("Export Format", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Preview
                ScrollView {
                    Text(previewText)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                
                // Actions
                HStack {
                    Button("Copy to Clipboard") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(previewText, forType: .string)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save to File...") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom)
            }
            .navigationTitle("Export Schema")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 700, height: 600)
        .onAppear {
            updatePreview()
        }
        .onChange(of: selectedFormat) { _, _ in
            updatePreview()
        }
        .fileExporter(
            isPresented: $showingFilePicker,
            document: ExportDocument(content: previewText, format: selectedFormat),
            contentType: contentType(for: selectedFormat),
            defaultFilename: defaultFilename(for: selectedFormat)
        ) { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
    }
    
    private func updatePreview() {
        switch selectedFormat {
        case .sql:
            previewText = MarkdownExporter.exportOracleSQL(session: sessionManager.currentSession)
        case .markdown:
            previewText = MarkdownExporter.exportSession(session: sessionManager.currentSession)
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(sessionManager.currentSession),
               let string = String(data: data, encoding: .utf8) {
                previewText = string
            }
        }
    }
    
    private func contentType(for format: ExportFormat) -> UTType {
        switch format {
        case .sql: return .plainText
        case .markdown: return .plainText
        case .json: return .json
        }
    }
    
    private func defaultFilename(for format: ExportFormat) -> String {
        let name = sessionManager.currentSession.name.replacingOccurrences(of: " ", with: "_")
        switch format {
        case .sql: return "\(name).sql"
        case .markdown: return "\(name).md"
        case .json: return "\(name).json"
        }
    }
}

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.plainText, .json]
    
    var content: String
    var format: ExportView.ExportFormat
    
    init(content: String, format: ExportView.ExportFormat) {
        self.content = content
        self.format = format
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = string
        self.format = .sql
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = content.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    ExportView()
        .environmentObject({
            let manager = SessionManager()
            manager.currentSession.nodes = [SchemaNode.example]
            return manager
        }())
}
