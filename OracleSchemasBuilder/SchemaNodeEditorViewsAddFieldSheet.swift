import SwiftUI

/// A modal sheet that lets the user create a new `TableField` and pass it back via a closure.
struct AddFieldSheet: View {
    // MARK: - Callback
    /// Called when the user taps “Add”.
    let onAdd: (TableField) -> Void

    // MARK: - Form state
    @State private var name = ""
    @State private var selectedFieldType: FieldType = .varchar2
    @State private var length = "255"          // for VARCHAR2 / CHAR
    @State private var precision = ""          // for NUMBER
    @State private var scale = ""              // for NUMBER
    @State private var isNullable = true
    @State private var isPrimaryKey = false
    @State private var isForeignKey = false
    @State private var defaultValue = ""
    @State private var comment = ""

    // MARK: - Dismiss environment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Basic information
                Section("Field Information") {
                    TextField("Field Name", text: $name)

                    Picker("Data Type", selection: $selectedFieldType) {
                        ForEach(FieldType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)

                    // Show length control for VARCHAR2 / CHAR
                    if selectedFieldType == .varchar2 || selectedFieldType == .char {
                        TextField("Length", text: $length)
                            .keyboardType(.numberPad)
                    }

                    // Show precision & scale controls for NUMBER
                    if selectedFieldType == .number {
                        TextField("Precision", text: $precision)
                            .keyboardType(.numberPad)
                        TextField("Scale", text: $scale)
                            .keyboardType(.numberPad)
                    }
                }

                // Constraints
                Section("Constraints") {
                    Toggle("Primary Key", isOn: $isPrimaryKey)
                    Toggle("Foreign Key", isOn: $isForeignKey)
                    Toggle("Not Null", isOn: Binding(
                        get: { !isNullable },
                        set: { isNullable = !$0 }
                    ))
                    // The existing `TableField` model does not currently expose a `unique` flag.
                    // If you need that feature, you can add it to the model and bind it here.
                }

                // Additional details
                Section("Additional") {
                    TextField("Default Value", text: $defaultValue)
                    TextField("Comment", text: $comment)
                }
            }
            .navigationTitle("Add Field")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // Convert string inputs to optional integers where appropriate
                        let intLength = Int(length)
                        let intPrecision = Int(precision)
                        let intScale = Int(scale)

                        let newField = TableField(
                            name: name,
                            fieldType: selectedFieldType,
                            length: intLength,
                            precision: intPrecision,
                            scale: intScale,
                            isNullable: isNullable,
                            isPrimaryKey: isPrimaryKey,
                            isForeignKey: isForeignKey,
                            defaultValue: defaultValue.isEmpty ? nil : defaultValue,
                            comment: comment
                        )
                        onAdd(newField)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}
