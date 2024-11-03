//
//  VehicleSelectionView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 03.11.24.
//


// VehicleSelectionView.swift

import SwiftUI
import SwiftData

struct VehicleSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query private var vehicles: [Vehicle]
    @Binding var selectedVehicle: Vehicle?
    @State private var newVehicleName: String = ""
    @State private var newVehicleType: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Vehicles")) {
                    ForEach(vehicles) { vehicle in
                        Button(action: {
                            selectedVehicle = vehicle
                            dismiss()
                        }) {
                            Text(vehicle.name)
                        }
                    }
                }
                Section(header: Text("Add New Vehicle")) {
                    TextField("Vehicle Name", text: $newVehicleName)
                    TextField("Vehicle Type", text: $newVehicleType)
                    Button("Add Vehicle") {
                        let newVehicle = Vehicle(name: newVehicleName, type: newVehicleType)
                        context.insert(newVehicle)
                        selectedVehicle = newVehicle
                        dismiss()
                    }
                    .disabled(newVehicleName.isEmpty || newVehicleType.isEmpty)
                }
            }
            .navigationTitle("Select Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}