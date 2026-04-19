//  OCIMonitoringService.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import Foundation

class OCIMonitoringService {
    private let config: OCIConfig
    private let client: MonitoringClient
    private let alertManager: AlertManager

    init(config: OCIConfig) {
        self.config = config
        self.client = MonitoringClient(config: config)
        self.alertManager = AlertManager.shared
    }

    // MARK: - Database Metrics

    func fetchDatabaseMetrics(compartmentId: String,
                             databaseId: String,
                             completion: @escaping (Result<DatabaseMetrics, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var cpuUtilization: [MetricDataPoint] = []
        var connections: Int = 0
        var storageUtilization: [MetricDataPoint] = []
        var error: Error?

        // Fetch CPU Utilization
        dispatchGroup.enter()
        fetchMetricData(
            namespace: "oci_database",
            metricName: "CpuUtilization",
            compartmentId: compartmentId,
            dimensions: ["resourceId": databaseId]
        ) { result in
            switch result {
            case .success(let points): cpuUtilization = points
            case .failure(let err): error = err
            }
            dispatchGroup.leave()
        }

        // Fetch Connections
        dispatchGroup.enter()
        fetchMetricData(
            namespace: "oci_database",
            metricName: "DatabaseConnections",
            compartmentId: compartmentId,
            dimensions: ["resourceId": databaseId]
        ) { result in
            switch result {
            case .success(let points): connections = Int(points.last?.value ?? 0)
            case .failure(let err): error = err
            }
            dispatchGroup.leave()
        }

        // Fetch Storage
        dispatchGroup.enter()
        fetchMetricData(
            namespace: "oci_database",
            metricName: "StorageUtilization",
            compartmentId: compartmentId,
            dimensions: ["resourceId": databaseId]
        ) { result in
            switch result {
            case .success(let points): storageUtilization = points
            case .failure(let err): error = err
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
                return
            }

            let metrics = DatabaseMetrics(
                cpuUtilization: cpuUtilization,
                connections: connections,
                storageUtilization: storageUtilization
            )

            completion(.success(metrics))
        }
    }

    // MARK: - Alert Checking

    func checkAlerts(for metrics: DatabaseMetrics) -> [Alert] {
        var alerts: [Alert] = []

        // Check CPU alerts
        if let cpuAlerts = alertManager.checkAlerts(
            metrics: metrics.cpuUtilization,
            metricName: "CpuUtilization",
            namespace: "oci_database"
        ) {
            alerts.append(contentsOf: cpuAlerts)
        }

        // Check connection alerts
        let connectionValue = Double(metrics.connections)
        let connectionPoint = MetricDataPoint(timestamp: Date(), value: connectionValue)
        if let connectionAlerts = alertManager.checkAlerts(
            metrics: [connectionPoint],
            metricName: "DatabaseConnections",
            namespace: "oci_database"
        ) {
            alerts.append(contentsOf: connectionAlerts)
        }

        return alerts
    }

    // MARK: - Private Helpers

    private func fetchMetricData(namespace: String,
                                metricName: String,
                                compartmentId: String,
                                dimensions: [String: String],
                                completion: @escaping (Result<[MetricDataPoint], Error>) -> Void) {
        let endTime = Date()
        let startTime = endTime.addingTimeInterval(-3600) // Last hour

        let request = GetMetricDataRequest(
            compartmentId: compartmentId,
            namespace: namespace,
            metricName: metricName,
            startTime: startTime,
            endTime: endTime,
            resolution: "1m",
            dimensions: dimensions
        )

        client.getMetricData(request: request) { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let points = response?.items?.compactMap { item in
                guard let timestamp = item.timestamp,
                      let value = item.value else { return nil }
                return MetricDataPoint(timestamp: timestamp, value: value)
            } ?? []

            completion(.success(points))
        }
    }
}

// Mock MonitoringClient for testing
class MonitoringClient {
    private let config: OCIConfig

    init(config: OCIConfig) {
        self.config = config
    }

    func getMetricData(request: GetMetricDataRequest, completion: @escaping ([MetricDataItem]?, Error?) -> Void) {
        // In a real implementation, this would call the OCI Monitoring API
        // For now, we'll return mock data

        let mockData: [MetricDataItem]

        switch request.metricName {
        case "CpuUtilization":
            mockData = (0..<60).map { i in
                let value = 40.0 + Double(i % 20)
                return MetricDataItem(timestamp: Date().addingTimeInterval(-Double(60-i)*60), value: value)
            }

        case "DatabaseConnections":
            let value = 350.0 + Double.random(in: 0..<100)
            mockData = [MetricDataItem(timestamp: Date(), value: value)]

        case "StorageUtilization":
            mockData = (0..<60).map { i in
                let value = 60.0 + Double(i % 30)
                return MetricDataItem(timestamp: Date().addingTimeInterval(-Double(60-i)*60), value: value)
            }

        default:
            mockData = []
        }

        completion(mockData, nil)
    }
}

// Mock data item for testing
struct MetricDataItem {
    let timestamp: Date
    let value: Double
}

// Mock request for testing
struct GetMetricDataRequest {
    let compartmentId: String
    let namespace: String
    let metricName: String
    let startTime: Date
    let endTime: Date
    let resolution: String
    let dimensions: [String: String]
}

// Mock OCI Config
struct OCIConfig {
    static let `default` = OCIConfig()
}
