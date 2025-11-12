# Schema Node Editor

A macOS application for visually designing Oracle database schemas using a node-based editor.

## Features

- **Visual Schema Design**: Create and arrange database tables on an infinite canvas
- **Node-Based Interface**: Drag and drop tables, connect relationships visually
- **Oracle SQL Support**: Export schemas as Oracle SQL DDL statements
- **Multiple Export Formats**: Export to SQL, Markdown, or JSON
- **Field Management**: Add and configure table fields with constraints
- **Relationship Mapping**: Define foreign key relationships between tables
- **Session Management**: Save and load your schema designs

## Architecture

### Models
- `SchemaNode`: Represents a database table
- `TableField`: Represents a column/field in a table
- `Connection`: Represents relationships between tables
- `Session`: Encapsulates a complete schema design session

### Views
- `ContentView`: Main application layout with sidebar and canvas
- `CanvasView`: Interactive canvas for node placement
- `NodeView`: Visual representation of a database table
- `InspectorView`: Property editor for selected nodes
- `ExportView`: Export interface with preview

### Services
- `SessionManager`: Manages application state and user actions
- `CanvasRenderer`: Renders connections and canvas elements
- `MarkdownExporter`: Generates export documents
- `SchemaStorage`: Handles file persistence

## Oracle Data Types Supported

### Numeric
- NUMBER, NUMBER(p,s)
- INTEGER, FLOAT
- BINARY_FLOAT, BINARY_DOUBLE

### Character
- VARCHAR2, CHAR
- NVARCHAR2, NCHAR
- CLOB, NCLOB

### Date/Time
- DATE, TIMESTAMP
- TIMESTAMP WITH TIME ZONE
- INTERVAL types

### Binary
- BLOB, RAW, LONG RAW

## Usage

1. **Create a Table**: Click "Add Table" or press Cmd+Shift+N
2. **Add Fields**: Select a table and use the inspector to add fields
3. **Configure Constraints**: Set primary keys, foreign keys, and other constraints
4. **Arrange Nodes**: Drag tables around the canvas to organize your schema
5. **Export**: Choose from SQL, Markdown, or JSON export formats

## Keyboard Shortcuts

- `⌘N`: New session
- `⇧⌘N`: New table
- `⌘S`: Save session
- `⌘E`: Export schema

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later

## Building

1. Open `SchemaNodeEditor.xcodeproj` in Xcode
2. Select the SchemaNodeEditor scheme
3. Build and run (⌘R)

## License

Copyright © 2025 Dennis Stewart Jr. All rights reserved.
