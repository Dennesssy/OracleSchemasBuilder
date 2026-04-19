//  MetricCardView.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: Double
    let unit: String
    let trend: Double?
    let status: MetricStatus
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection

            valueSection

            if let trend = trend {
                trendSection(trend)
            }

            Spacer()

            statusSection
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor, lineWidth: 1)
        )
    }

    private var headerSection: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Image(systemName: iconName)
                .foregroundColor(statusColor)
        }
    }

    private var valueSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.1f", value))
                .font(.system(size: 24, weight: .bold))

            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func trendSection(_ trend: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: trend > 0 ? "arrow.up" : "arrow.down")
                .font(.caption)
            Text(String(format: "%.1f%%", abs(trend)))
                .font(.caption)
            Text(trend > 0 ? "increase" : "decrease")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var statusSection: some View {
        HStack {
            Text("Status")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            statusIndicator
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(statusColor)

            Text(statusText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
    }

    private var statusText: String {
        switch status {
        case .normal: return "Normal"
        case .warning: return "Warning"
        case .critical: return "Critical"
        }
    }

    private var statusColor: Color {
        switch status {
        case .normal: return Color(.systemGreen)
        case .warning: return Color(.systemOrange)
        case .critical: return Color(.systemRed)
        }
    }
}

// MARK: - Preview

struct MetricCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MetricCardView(
                title: "CPU Utilization",
                value: 45.2,
                unit: "%",
                trend: 12.5,
                status: .normal,
                iconName: "cpu"
            )

            MetricCardView(
                title: "Database Connections",
                value: 387,
                unit: "active",
                trend: nil,
                status: .warning,
                iconName: "network"
            )

            MetricCardView(
                title: "Storage Utilization",
                value: 88.4,
                unit: "%",
                trend: -5.2,
                status: .critical,
                iconName: "externaldrive"
            )
        }
        .padding()
        .frame(width: 300)
    }
}
