//
//  VehicleSelectionView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 03.11.24.
//

import SwiftUI
import SwiftData

struct VehicleSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query private var vehicles: [Vehicle]
    @Binding var selectedVehicle: Vehicle?
    @State private var newVehicleName: String = ""
    @State private var newVehicleType: String = ""
    @State private var vehicleToShowDetails: Vehicle?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Vehicles")) {
                    ForEach(vehicles) { vehicle in
                        HStack {
                            Button(action: {
                                selectedVehicle = vehicle
                                dismiss()
                            }) {
                                Text(vehicle.name)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Spacer()
                            // Replace NavigationLink with Button to present VehicleDetailView
                            Button(action: {
                                vehicleToShowDetails = vehicle
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                Section(header: Text("Add New Vehicle")) {
                    TextField("Vehicle Name", text: $newVehicleName)
                    TextField("Vehicle Type", text: $newVehicleType)
                    Button("Add Vehicle") {
                        let newVehicle = Vehicle(name: newVehicleName, type: newVehicleType)
                        context.insert(newVehicle)
                        // Save the context
                        do {
                            try context.save()
                            print("Vehicle saved successfully.")
                        } catch {
                            print("Failed to save vehicle: \(error)")
                        }
                        selectedVehicle = newVehicle
                        dismiss()
                    }
                    .disabled(newVehicleName.isEmpty || newVehicleType.isEmpty)
                }
            }
            .onAppear {
                print("Number of vehicles fetched: \(vehicles.count)")
                for vehicle in vehicles {
                    print("Vehicle: \(vehicle.name), Type: \(vehicle.type)")
                }
            }
            .navigationTitle("Select Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            // Present the VehicleDetailView as a sheet
            .sheet(item: $vehicleToShowDetails) { vehicle in
                VehicleDetailView(vehicle: vehicle)
            }
        }
    }
}
