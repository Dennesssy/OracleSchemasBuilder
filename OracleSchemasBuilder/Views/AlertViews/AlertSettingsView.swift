//  AlertSettingsView.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import SwiftUI

struct AlertSettingsView: View {
    @Binding var alertConfig: AlertConfiguration
    @State private var showingTestAlert = false
    @State private var testAlertMessage = ""

    var body: some View {
        Form {
            // CPU Alerts Section
            Section(header: Text("CPU Utilization Alerts")) {
                cpuAlertSection
            }

            // Connection Alerts Section
            Section(header: Text("Database Connection Alerts")) {
                connectionAlertSection
            }

            // Notification Settings Section
            Section(header: Text("Notification Preferences")) {
                notificationSettingsSection
            }

            // Actions Section
            Section {
                testAlertButton
                resetButton
            }
        }
        .navigationTitle("Alert Settings")
        .padding()
        .alert("Test Alert", isPresented: $showingTestAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(testAlertMessage)
        }
    }

    // MARK: - CPU Alert Section

    private var cpuAlertSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Critical Threshold")
                    .font(.headline)

                HStack {
                    Text("Trigger when CPU exceeds")
                    Spacer()
                    Text(" \(Int(alertConfig.cpuCriticalThreshold))% ")
                        .frame(width: 60)
                }

                Slider(
                    value: $alertConfig.cpuCriticalThreshold,
                    in: 70...100,
                    step: 1
                )

                Toggle("Enable Critical Alert", isOn: $alertConfig.cpuCriticalEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Warning Threshold")
                    .font(.headline)

                HStack {
                    Text("Trigger when CPU exceeds")
                    Spacer()
                    Text(" \(Int(alertConfig.cpuWarningThreshold))% ")
                        .frame(width: 60)
                }

                Slider(
                    value: $alertConfig.cpuWarningThreshold,
                    in: 50...90,
                    step: 1
                )

                Toggle("Enable Warning Alert", isOn: $alertConfig.cpuWarningEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
            }
        }
    }

    // MARK: - Connection Alert Section

    private var connectionAlertSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Maximum Connections")
                .font(.headline)

            HStack {
                Text("Alert when connections exceed")
                Spacer()
                Text(" \(Int(alertConfig.maxConnections)) ")
                    .frame(width: 60)
            }

            Slider(
                value: $alertConfig.maxConnections,
                in: 100...1000,
                step: 10
            )

            Toggle("Enable Connection Alert", isOn: $alertConfig.connectionAlertEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .red))
        }
    }

    // MARK: - Notification Settings Section

    private var notificationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("In-App Notifications", isOn: $alertConfig.notifyInApp)

            Toggle("Email Notifications", isOn: $alertConfig.notifyViaEmail)

            Toggle("SMS Notifications", isOn: $alertConfig.notifyViaSMS)
        }
    }

    // MARK: - Action Buttons

    private var testAlertButton: some View {
        Button(action: {
            testAlertMessage = "Test alert triggered at \(Date().formatted(.dateTime))"
            showingTestAlert = true
        }) {
            HStack {
                Spacer()
                Text("Test Alert Notification")
                Spacer()
            }
        }
    }

    private var resetButton: some View {
        Button(action: {
            alertConfig = AlertConfiguration()
        }) {
            HStack {
                Spacer()
                Text("Reset to Defaults")
                    .foregroundColor(.red)
                Spacer()
            }
        }
    }
}

// Preview
struct AlertSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlertSettingsView(alertConfig: .constant(AlertConfiguration()))
        }
    }
}
