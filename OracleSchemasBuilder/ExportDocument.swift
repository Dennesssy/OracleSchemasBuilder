import SwiftUI
import UniformTypeIdentifiers

/// A minimal `FileDocument` used by `ExportView` for the file exporter.
struct ExportDocument: FileDocument {
    // The exporter only writes, never reads
    static var readableContentTypes: [UTType] { [] }
    static var writableContentTypes: [UTType] { [.plainText] }

    var content: String
    var format: ExportView.ExportFormat

    init(content: String, format: ExportView.ExportFormat) {
        self.content = content
        self.format = format
    }

    init(configuration: ReadConfiguration) throws {
        // Reading is not supported; provide default values
        self.content = ""
        self.format = .sql
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}
