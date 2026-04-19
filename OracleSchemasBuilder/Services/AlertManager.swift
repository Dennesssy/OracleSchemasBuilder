//  AlertManager.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import Foundation

class AlertManager {
    static let shared = AlertManager()
    private var config: AlertConfiguration = AlertConfiguration()

    private init() {
        loadConfig()
    }

    func updateConfig(_ config: AlertConfiguration) {
        self.config = config
        saveConfig()
    }

    func getCurrentConfig() -> AlertConfiguration {
        return config
    }

    func checkAlerts(metrics: [MetricDataPoint], metricName: String, namespace: String) -> [Alert] {
        guard !metrics.isEmpty else { return [] }

        switch (namespace, metricName) {
        case ("oci_database", "CpuUtilization"):
            return checkCPUAlerts(metrics)

        case ("oci_database", "DatabaseConnections"):
            return checkConnectionAlerts(metrics)

        default:
            return []
        }
    }

    private func checkCPUAlerts(_ metrics: [MetricDataPoint]) -> [Alert] {
        var alerts: [Alert] = []
        let latest = metrics.last!.value

        // Check critical
        if config.cpuCriticalEnabled && latest > config.cpuCriticalThreshold {
            alerts.append(createAlert(
                metricName: "CpuUtilization",
                severity: .critical,
                value: latest,
                threshold: config.cpuCriticalThreshold,
                message: "CPU utilization exceeded critical threshold: \(String(format: "%.1f", latest))%",
                recommendedAction: "Consider adding CPU resources or optimizing queries"
            ))
        }
        // Check warning
        else if config.cpuWarningEnabled && latest > config.cpuWarningThreshold {
            alerts.append(createAlert(
                metricName: "CpuUtilization",
                severity: .warning,
                value: latest,
                threshold: config.cpuWarningThreshold,
                message: "CPU utilization exceeded warning threshold: \(String(format: "%.1f", latest))%"
            ))
        }

        return alerts
    }

    private func checkConnectionAlerts(_ metrics: [MetricDataPoint]) -> [Alert] {
        guard config.connectionAlertEnabled else { return [] }

        let latest = metrics.last!.value

        if latest > config.maxConnections {
            return [createAlert(
                metricName: "DatabaseConnections",
                severity: .critical,
                value: latest,
                threshold: config.maxConnections,
                message: "Database connections exceeded maximum: \(Int(latest)) connections",
                recommendedAction: "Review active connections and consider connection pooling"
            )]
        }

        return []
    }

    private func createAlert(metricName: String,
                            severity: AlertSeverity,
                            value: Double,
                            threshold: Double,
                            message: String,
                            recommendedAction: String? = nil) -> Alert {
        return Alert(
            name: "\(metricName)_\(severity)",
            metricName: metricName,
            severity: severity,
            value: value,
            threshold: threshold,
            message: message,
            recommendedAction: recommendedAction
        )
    }

    // MARK: - Persistence

    private func saveConfig() {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: "alertConfiguration")
        }
    }

    private func loadConfig() {
        if let data = UserDefaults.standard.data(forKey: "alertConfiguration"),
           let config = try? JSONDecoder().decode(AlertConfiguration.self, from: data) {
            self.config = config
        }
    }

    // MARK: - Notification Handling

    func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func showNotification(for alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = "\(alert.severity.rawValue) Alert"
        content.body = alert.message
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
