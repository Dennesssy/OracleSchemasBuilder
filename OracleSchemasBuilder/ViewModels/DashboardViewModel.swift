//  DashboardViewModel.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import Combine
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var metrics: DatabaseMetrics?
    @Published var alerts: [Alert] = []
    @Published var alertConfig = AlertConfiguration()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showAlertSettings = false
    @Published var selectedAlert: Alert?

    private let monitoringService: OCIMonitoringService
    private let compartmentId: String
    private let databaseId: String
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(compartmentId: String, databaseId: String) {
        self.compartmentId = compartmentId
        self.databaseId = databaseId
        self.monitoringService = OCIMonitoringService(config: OCIConfig.default)

        setupObservers()
        loadAlertConfig()
        startAutoRefresh()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Setup

    private func setupObservers() {
        $alertConfig
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveAlertConfig()
            }
            .store(in: &cancellables)
    }

    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchMetrics()
        }
        fetchMetrics() // Initial fetch
    }

    // MARK: - Data Fetching

    func fetchMetrics() {
        isLoading = true
        error = nil

        monitoringService.fetchDatabaseMetrics(
            compartmentId: compartmentId,
            databaseId: databaseId
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let metrics):
                    self?.metrics = metrics
                    self?.checkForAlerts(metrics: metrics)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }

    private func checkForAlerts(metrics: DatabaseMetrics) {
        // Update alert manager with current config
        AlertManager.shared.updateConfig(alertConfig)

        // Check for new alerts
        let newAlerts = monitoringService.checkAlerts(for: metrics)

        // Only show new alerts (not duplicates)
        let existingAlertIds = Set(alerts.map { $0.id })
        let trulyNewAlerts = newAlerts.filter { !existingAlertIds.contains($0.id) }

        if !trulyNewAlerts.isEmpty {
            alerts.insert(contentsOf: trulyNewAlerts, at: 0)

            // Show notification for critical alerts
            trulyNewAlerts.forEach { alert in
                if alert.severity == .critical && alertConfig.notifyInApp {
                    showNotification(for: alert)
                }
            }
        }
    }

    private func showNotification(for alert: Alert) {
        // In a real app, this would show a system notification
        print("ALERT: \(alert.message)")
        // You could also use UNUserNotificationCenter here
    }

    // MARK: - Alert Configuration

    private func saveAlertConfig() {
        if let encoded = try? JSONEncoder().encode(alertConfig) {
            UserDefaults.standard.set(encoded, forKey: "alertConfiguration")
        }
    }

    private func loadAlertConfig() {
        if let data = UserDefaults.standard.data(forKey: "alertConfiguration"),
           let config = try? JSONDecoder().decode(AlertConfiguration.self, from: data) {
            alertConfig = config
        }
    }

    // MARK: - Status Helpers

    func getCPUStatus() -> MetricStatus {
        guard let value = metrics?.cpuUtilization.last?.value else {
            return .normal
        }

        if value > alertConfig.cpuCriticalThreshold {
            return .critical
        } else if value > alertConfig.cpuWarningThreshold {
            return .warning
        }
        return .normal
    }

    func getConnectionStatus() -> MetricStatus {
        guard let connections = metrics?.connections else {
            return .normal
        }

        if Double(connections) > alertConfig.maxConnections {
            return .critical
        }
        return .normal
    }

    func getStorageStatus() -> MetricStatus {
        guard let value = metrics?.storageUtilization.last?.value else {
            return .normal
        }

        if value > 90 {
            return .critical
        } else if value > 80 {
            return .warning
        }
        return .normal
    }

    func calculateCPUTrend() -> Double? {
        guard let metrics = metrics?.cpuUtilization,
              metrics.count >= 2 else { return nil }

        let current = metrics.last!.value
        let previous = metrics[metrics.count - 2].value
        return ((current - previous) / previous) * 100
    }
}
