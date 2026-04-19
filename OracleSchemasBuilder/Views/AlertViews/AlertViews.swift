//  AlertViews.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import SwiftUI

// MARK: - Alert Banner

struct AlertBanner: View {
    let alert: Alert
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                alertIcon

                Text(alert.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(severityColor)

                Spacer()

                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text(alert.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(alert.message)
                .font(.subheadline)

            if let recommendedAction = alert.recommendedAction {
                Text("Recommended: \(recommendedAction)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(severityColor.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(severityColor, lineWidth: 1)
        )
    }

    private var alertIcon: some View {
        Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
            .foregroundColor(severityColor)
    }

    private var severityColor: Color {
        alert.severity == .critical ? .red : .orange
    }
}

// MARK: - Alert Row

struct AlertRow: View {
    let alert: Alert

    var body: some View {
        HStack(spacing: 12) {
            alertIcon

            VStack(alignment: .leading, spacing: 2) {
                Text(alert.message)
                    .font(.subheadline)
                    .lineLimit(1)

                HStack {
                    Text(alert.severity.rawValue)
                        .font(.caption)
                        .foregroundColor(severityColor)

                    Text("•")

                    Text(alert.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private var alertIcon: some View {
        Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
            .foregroundColor(severityColor)
    }

    private var severityColor: Color {
        alert.severity == .critical ? .red : .orange
    }
}

// MARK: - Alert Detail View

struct AlertDetailView: View {
    let alert: Alert
    var onAcknowledge: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            alertHeader

            Divider()

            metricDetails

            if let recommendedAction = alert.recommendedAction {
                Divider()
                recommendedActionSection(recommendedAction)
            }

            Spacer()

            acknowledgeButton
        }
        .padding()
        .navigationTitle("Alert Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var alertHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                    .foregroundColor(severityColor)

                Text(alert.severity.rawValue)
                    .font(.headline)
                    .foregroundColor(severityColor)
            }

            Text(alert.timestamp, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var metricDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Metric")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(alert.metricName)
                .font(.body)

            HStack {
                Text("Current Value:")
                Text(" \(String(format: "%.2f", alert.value))")
                    .fontWeight(.semibold)
            }

            HStack {
                Text("Threshold:")
                Text(" \(String(format: "%.2f", alert.threshold))")
                    .fontWeight(.semibold)
            }
        }
    }

    private func recommendedActionSection(_ action: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended Action")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(action)
                .font(.body)
        }
    }

    private var acknowledgeButton: some View {
        Button(action: {
            onAcknowledge?()
        }) {
            Text("Acknowledge Alert")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private var severityColor: Color {
        alert.severity == .critical ? .red : .orange
    }
}

// MARK: - Alerts Section

struct AlertsSection: View {
    let alerts: [Alert]
    @Binding var selectedAlert: Alert?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Alerts")
                    .font(.headline)

                Spacer()

                if !alerts.isEmpty {
                    Text(" \(alerts.count) total ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if alerts.isEmpty {
                emptyState
            } else {
                alertsList
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var emptyState: some View {
        Text("No recent alerts")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }

    private var alertsList: some View {
        ForEach(alerts.prefix(5)) { alert in
            Button(action: {
                selectedAlert = alert
            }) {
                AlertRow(alert: alert)
            }
            .buttonStyle(PlainButtonStyle())

            if alert.id != alerts.last?.id {
                Divider()
            }
        }
    }
}

// MARK: - Previews

struct AlertBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AlertBanner(
                alert: Alert(
                    name: "HighCPU",
                    metricName: "CpuUtilization",
                    severity: .critical,
                    value: 92.5,
                    threshold: 90,
                    message: "CPU utilization exceeded critical threshold: 92.5%",
                    recommendedAction: "Consider adding CPU resources"
                )
            )
            .padding()

            AlertBanner(
                alert: Alert(
                    name: "HighConnections",
                    metricName: "DatabaseConnections",
                    severity: .warning,
                    value: 450,
                    threshold: 400,
                    message: "Database connections approaching limit: 450 connections"
                )
            )
            .padding()
        }
    }
}

struct AlertRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AlertRow(
                alert: Alert(
                    name: "HighCPU",
                    metricName: "CpuUtilization",
                    severity: .critical,
                    value: 92.5,
                    threshold: 90,
                    timestamp: Date(),
                    message: "CPU utilization exceeded critical threshold: 92.5%"
                )
            )

            AlertRow(
                alert: Alert(
                    name: "HighConnections",
                    metricName: "DatabaseConnections",
                    severity: .warning,
                    value: 450,
                    threshold: 400,
                    timestamp: Date(),
                    message: "Database connections approaching limit: 450 connections"
                )
            )
        }
    }
}

struct AlertDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlertDetailView(
                alert: Alert(
                    name: "HighCPU",
                    metricName: "CpuUtilization",
                    severity: .critical,
                    value: 92.5,
                    threshold: 90,
                    timestamp: Date(),
                    message: "CPU utilization exceeded critical threshold: 92.5%",
                    recommendedAction: "Consider adding CPU resources or optimizing queries"
                )
            )
        }
    }
}
