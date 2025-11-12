import SwiftUI
import UniformTypeIdentifiers

/// A file document that holds the exported schema text.
/// It can be written to the filesystem as a plain‑text file.
struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [] }
    static var writableContentTypes: [UTType] { [.plainText] }

    var content: String
    var format: ExportView.ExportFormat

    init(content: String, format: ExportView.ExportFormat) {
        self.content = content
        self.format = format
    }

    init(configuration: ReadConfiguration) throws {
        self.content = ""
        self.format = .sql
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}

/// The view presented in a sheet to export the current session.
/// It lets the user choose a format, generates the export string,
/// and shows a share link for the resulting file.
struct ExportView: View {
    enum ExportFormat: String, CaseIterable, Identifiable {
        case sql, markdown, json
        var id: String { rawValue }
        var title: String { rawValue.uppercased() }
    }

    @EnvironmentObject var sessionManager: SessionManager
    @State private var format: ExportFormat = .sql
    @State private var document: ExportDocument?

    var body: some View {
        NavigationView {
            List {
                Picker("Format", selection: $format) {
                    ForEach(ExportFormat.allCases) { fmt in
                        Text(fmt.title).tag(fmt)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)

                Button("Generate Export") {
                    let content = generateExport(for: format)
                    document = ExportDocument(content: content, format: format)
                }
            }
            .navigationTitle("Export Schema")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if let document {
                        ShareLink(item: document) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(item: $document) { doc in
            ExportDocumentView(document: doc)
        }
    }

    func generateExport(for format: ExportFormat) -> String {
        // Placeholder export logic – replace with real generation.
        switch format {
        case .sql:
            return "-- SQL DDL export – placeholder"
        case .markdown:
            return "# Schema Export\n\n- TODO"
        case .json:
            return "{}"
        }
    }

    private func dismiss() {
        // Dismiss the sheet by clearing the document.
        document = nil
    }
}

/// A simple view that displays the exported content
/// and allows the user to close the sheet.
struct ExportDocumentView: View {
    let document: ExportDocument

    var body: some View {
        VStack {
            TextEditor(text: .constant(document.content))
                .disabled(true)
            Button("Close") {
                // The sheet will be dismissed by the parent view.
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
