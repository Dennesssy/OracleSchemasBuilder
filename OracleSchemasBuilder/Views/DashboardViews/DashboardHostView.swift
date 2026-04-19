//  DashboardHostView.swift
//  OracleSchemasBuilder
//
//  Created by Dennis Stewart Jr. on 2/15/24.
//  Copyright © 2024 Dennis Stewart Jr. All rights reserved.

import SwiftUI

struct DashboardHostView: View {
    // In a real app, these would come from your configuration
    // For now, we'll use placeholder values
    private let compartmentId = "ocid1.compartment.oc1..exampleuniqueID"
    private let databaseId = "ocid1.database.oc1..exampleuniqueID"

    var body: some View {
        DashboardView(compartmentId: compartmentId, databaseId: databaseId)
    }
}

struct DashboardHostView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardHostView()
    }
}
