//  DashboardView.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showingAlertSettings = false

    init(compartmentId: String, databaseId: String) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            compartmentId: compartmentId,
            databaseId: databaseId
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Alert Banner (if any critical alerts)
                    alertBannerSection

                    // Metrics Cards
                    metricsCardsSection

                    // Alerts Section
                    alertsSection

                    // Sample Query (from your existing UI)
                    sampleQuerySection
                }
                .padding()
            }
            .navigationTitle("Database Dashboard")
            .toolbar {
                toolbarItems
            }
            .sheet(isPresented: $viewModel.showAlertSettings) {
                alertSettingsSheet
            }
            .sheet(item: $viewModel.selectedAlert) { alert in
                alertDetailSheet(for: alert)
            }
            .overlay {
                loadingOverlay
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                errorAlertButtons
            } message: {
                errorMessage
            }
        }
    }

    // MARK: - View Sections

    private var alertBannerSection: some View {
        Group {
            if let criticalAlert = viewModel.alerts.first(where: { $0.severity == .critical }) {
                AlertBanner(alert: criticalAlert) {
                    viewModel.alerts.removeAll { $0.id == criticalAlert.id }
                }
                .onTapGesture {
                    viewModel.selectedAlert = criticalAlert
                }
            }
        }
    }

    private var metricsCardsSection: some View {
        VStack(spacing: 16) {
            // First row
            HStack(spacing: 16) {
                cpuMetricCard
                connectionMetricCard
            }

            // Second row
            HStack(spacing: 16) {
                storageMetricCard
                Spacer()
            }
        }
    }

    private var alertsSection: some View {
        AlertsSection(alerts: viewModel.alerts, selectedAlert: $viewModel.selectedAlert)
    }

    private var sampleQuerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sample Query")
                .font(.headline)

            Text("Top 10 customers by revenue")
                .font(.subheadline)
                .foregroundColor(.secondary)

            sampleQueryCode
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Individual Metric Cards

    private var cpuMetricCard: some View {
        Group {
            if let metrics = viewModel.metrics {
                MetricCardView(
                    title: "CPU Utilization",
                    value: metrics.cpuUtilization.last?.value ?? 0,
                    unit: "%",
                    trend: viewModel.calculateCPUTrend(),
                    status: viewModel.getCPUStatus(),
                    iconName: "cpu"
                )
            } else {
                loadingMetricCard(title: "CPU Utilization")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var connectionMetricCard: some View {
        Group {
            if let metrics = viewModel.metrics {
                MetricCardView(
                    title: "Connections",
                    value: Double(metrics.connections),
                    unit: "active",
                    trend: nil,
                    status: viewModel.getConnectionStatus(),
                    iconName: "network"
                )
            } else {
                loadingMetricCard(title: "Connections")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var storageMetricCard: some View {
        Group {
            if let metrics = viewModel.metrics {
                MetricCardView(
                    title: "Storage Utilization",
                    value: metrics.storageUtilization.last?.value ?? 0,
                    unit: "%",
                    trend: nil,
                    status: viewModel.getStorageStatus(),
                    iconName: "externaldrive"
                )
            } else {
                loadingMetricCard(title: "Storage Utilization")
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Toolbar Items

    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                alertSettingsButton
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                refreshButton
            }
        }
    }

    private var alertSettingsButton: some View {
        Button(action: {
            viewModel.showAlertSettings = true
        }) {
            Image(systemName: "bell")
        }
    }

    private var refreshButton: some View {
        Button(action: {
            viewModel.fetchMetrics()
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }

    // MARK: - Sheets

    private var alertSettingsSheet: some View {
        NavigationView {
            AlertSettingsView(alertConfig: $viewModel.alertConfig)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            viewModel.showAlertSettings = false
                        }
                    }
                }
        }
    }

    private func alertDetailSheet(for alert: Alert) -> some View {
        NavigationView {
            AlertDetailView(alert: alert) {
                viewModel.alerts.removeAll { $0.id == alert.id }
                viewModel.selectedAlert = nil
            }
        }
    }

    // MARK: - Loading States

    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
        }
    }

    private func loadingMetricCard(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Error Handling

    private var errorAlertButtons: some View {
        Group {
            Button("OK") { viewModel.error = nil }
            Button("Retry") { viewModel.fetchMetrics() }
        }
    }

    private var errorMessage: some View {
        Text(viewModel.error?.localizedDescription ?? "Unknown error")
    }

    // MARK: - Sample Query

    private var sampleQueryCode: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text("""
            -- Customer Performance Analysis
            SELECT c.cust_id, c.cust_first_name, c.cust_last_name,
                   SUM(s.amount_sold) AS total_revenue,
                   c.country_id, c.cust_city
            FROM customers c
            JOIN sales s ON c.cust_id = s.cust_id
            GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name,
                     c.country_id, c.cust_city
            ORDER BY total_revenue DESC
            FETCH FIRST 10 ROWS ONLY;
            """)
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(6)
        }
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a view model with sample data
        let viewModel = DashboardViewModel(compartmentId: "preview", databaseId: "preview")

        // Inject sample metrics
        let sampleMetrics = DatabaseMetrics(
            cpuUtilization: (0..<10).map { i in
                MetricDataPoint(timestamp: Date().addingTimeInterval(-Double(10-i)*60), value: 45 + Double(i * 2))
            },
            connections: 420,
            storageUtilization: (0..<10).map { i in
                MetricDataPoint(timestamp: Date().addingTimeInterval(-Double(10-i)*60), value: 65 + Double(i))
            }
        )

        viewModel.metrics = sampleMetrics

        // Add a sample alert
        viewModel.alerts = [
            Alert(
                name: "HighCPU",
                metricName: "CpuUtilization",
                severity: .warning,
                value: 85,
                threshold: 80,
                timestamp: Date(),
                message: "CPU utilization exceeded warning threshold: 85.0%",
                recommendedAction: "Monitor CPU usage"
            )
        ]

        return DashboardView(compartmentId: "preview", databaseId: "preview")
            .environmentObject(viewModel)
    }
}
