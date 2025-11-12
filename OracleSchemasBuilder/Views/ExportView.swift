import SwiftUI
import UniformTypeIdentifiers
import OSLog

private let exportLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SchemaNodeEditor", category: "Export")

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
        
        var fileExtension: String {
            switch self {
            case .sql: return "sql"
            case .markdown: return "md"
            case .json: return "json"
            }
        }
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
                    .accessibilityIdentifier("copyToClipboardButton")
                    
                    Button("Save to File…") {
                        showingFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("saveToFileButton")
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
            document: ExportDocument(content: previewText),
            contentType: contentType(for: selectedFormat),
            defaultFilename: defaultFilename(for: selectedFormat)
        ) { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                exportLogger.error("Export failed: \(error.localizedDescription)")
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
        case .sql, .markdown:
            return .plainText
        case .json:
            return .json
        }
    }
    
    private func defaultFilename(for format: ExportFormat) -> String {
        let name = sessionManager.currentSession.name.replacingOccurrences(of: " ", with: "_")
        return "\(name).\(format.fileExtension)"
    }
}
