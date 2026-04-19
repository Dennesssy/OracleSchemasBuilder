//  MetricModels.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import Foundation

// MARK: - Core Data Models

struct MetricDataPoint: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double

    init(timestamp: Date, value: Double) {
        self.timestamp = timestamp
        self.value = value
    }
}

struct DatabaseMetrics: Codable {
    let cpuUtilization: [MetricDataPoint]
    let connections: Int
    let storageUtilization: [MetricDataPoint]
}

// MARK: - Alert Models

enum AlertSeverity: String, Codable, CaseIterable {
    case critical = "CRITICAL"
    case warning = "WARNING"
    case info = "INFO"
}

struct Alert: Codable, Identifiable {
    let id: String
    let name: String
    let metricName: String
    let severity: AlertSeverity
    let value: Double
    let threshold: Double
    let timestamp: Date
    let message: String
    let recommendedAction: String?

    init(id: String = UUID().uuidString,
         name: String,
         metricName: String,
         severity: AlertSeverity,
         value: Double,
         threshold: Double,
         timestamp: Date = Date(),
         message: String,
         recommendedAction: String? = nil) {
        self.id = id
        self.name = name
        self.metricName = metricName
        self.severity = severity
        self.value = value
        self.threshold = threshold
        self.timestamp = timestamp
        self.message = message
        self.recommendedAction = recommendedAction
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Configuration Models

struct AlertConfiguration: Codable {
    // CPU Alerts
    var cpuCriticalThreshold: Double = 90
    var cpuCriticalEnabled: Bool = true
    var cpuWarningThreshold: Double = 80
    var cpuWarningEnabled: Bool = true

    // Connection Alerts
    var maxConnections: Double = 500
    var connectionAlertEnabled: Bool = true

    // Notification Settings
    var notifyViaEmail: Bool = true
    var notifyViaSMS: Bool = false
    var notifyInApp: Bool = true

    init() {}

    init(cpuCriticalThreshold: Double = 90,
         cpuCriticalEnabled: Bool = true,
         cpuWarningThreshold: Double = 80,
         cpuWarningEnabled: Bool = true,
         maxConnections: Double = 500,
         connectionAlertEnabled: Bool = true,
         notifyViaEmail: Bool = true,
         notifyViaSMS: Bool = false,
         notifyInApp: Bool = true) {
        self.cpuCriticalThreshold = cpuCriticalThreshold
        self.cpuCriticalEnabled = cpuCriticalEnabled
        self.cpuWarningThreshold = cpuWarningThreshold
        self.cpuWarningEnabled = cpuWarningEnabled
        self.maxConnections = maxConnections
        self.connectionAlertEnabled = connectionAlertEnabled
        self.notifyViaEmail = notifyViaEmail
        self.notifyViaSMS = notifyViaSMS
        self.notifyInApp = notifyInApp
    }
}

// MARK: - Status Models

enum MetricStatus: String, Codable {
    case normal = "NORMAL"
    case warning = "WARNING"
    case critical = "CRITICAL"

    var colorName: String {
        switch self {
        case .normal: return "systemGreen"
        case .warning: return "systemOrange"
        case .critical: return "systemRed"
        }
    }
}

// MARK: - Time Range

enum TimeRange: TimeInterval {
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case oneHour = 3600
    case sixHours = 21600
    case oneDay = 86400
    case sevenDays = 604800
}

// MARK: - Metric Type

enum MetricType {
    case cpu
    case connections
    case storage
}
