//
//  SchemaStorage.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation

class SchemaStorage {
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var schemasDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Schemas", isDirectory: true)
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    init() {
        encoder.outputFormatting = .prettyPrinted
    }
    
    // MARK: - Save/Load
    
    func save(session: Session) {
        let filename = "\(session.id.uuidString).json"
        let fileURL = schemasDirectory.appendingPathComponent(filename)
        
        do {
            let data = try encoder.encode(session)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    func load(sessionId: UUID) -> Session? {
        let filename = "\(sessionId.uuidString).json"
        let fileURL = schemasDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(Session.self, from: data)
        } catch {
            print("Failed to load session: \(error)")
            return nil
        }
    }
    
    func listSessions() -> [Session] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: schemasDirectory,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "json" }
            
            return fileURLs.compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let session = try? decoder.decode(Session.self, from: data) else {
                    return nil
                }
                return session
            }.sorted { $0.modifiedAt > $1.modifiedAt }
        } catch {
            print("Failed to list sessions: \(error)")
            return []
        }
    }
    
    func delete(sessionId: UUID) {
        let filename = "\(sessionId.uuidString).json"
        let fileURL = schemasDirectory.appendingPathComponent(filename)
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Export
    
    func exportToURL(session: Session, as url: URL, format: ExportFormat) throws {
        let content: String
        
        switch format {
        case .markdown:
            content = MarkdownExporter().exportSession(session)
        case .sql:
            content = MarkdownExporter().exportOracleSQL(session)
        case .json:
            let data = try encoder.encode(session)
            try data.write(to: url)
            return
        }
        
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    enum ExportFormat {
        case markdown
        case sql
        case json
    }
}
