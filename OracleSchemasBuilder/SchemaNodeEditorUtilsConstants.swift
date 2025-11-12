//
//  Constants.swift
//  SchemaNodeEditor
//
//  Created by Dennis Stewart Jr. on 11/11/25.
//

import Foundation
import CoreGraphics

enum Constants {
    // MARK: - Canvas
    enum Canvas {
        static let gridSpacing: CGFloat = 20
        static let defaultZoom: CGFloat = 1.0
        static let minZoom: CGFloat = 0.5
        static let maxZoom: CGFloat = 2.0
    }
    
    // MARK: - Node
    enum Node {
        static let width: CGFloat = 300
        static let minHeight: CGFloat = 100
        static let cornerRadius: CGFloat = 8
        static let shadowRadius: CGFloat = 4
    }
    
    // MARK: - Connection
    enum Connection {
        static let lineWidth: CGFloat = 2
        static let arrowSize: CGFloat = 10
    }
    
    // MARK: - Oracle Data Types
    enum OracleDataTypes {
        static let numeric = [
            "NUMBER",
            "NUMBER(p,s)",
            "INTEGER",
            "FLOAT",
            "BINARY_FLOAT",
            "BINARY_DOUBLE"
        ]
        
        static let character = [
            "VARCHAR2(size)",
            "CHAR(size)",
            "NVARCHAR2(size)",
            "NCHAR(size)",
            "CLOB",
            "NCLOB"
        ]
        
        static let dateTime = [
            "DATE",
            "TIMESTAMP",
            "TIMESTAMP WITH TIME ZONE",
            "TIMESTAMP WITH LOCAL TIME ZONE",
            "INTERVAL YEAR TO MONTH",
            "INTERVAL DAY TO SECOND"
        ]
        
        static let binary = [
            "BLOB",
            "RAW(size)",
            "LONG RAW"
        ]
        
        static let all: [String] = numeric + character + dateTime + binary
    }
}
