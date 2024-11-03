//
//  VehicleDetailView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 03.11.24.
//

import SwiftUI
import SwiftData
import MapKit

struct VehicleDetailView: View {
    var vehicle: Vehicle
    @Environment(\.modelContext) private var context
    @Query(sort: \DataItem.time) private var dataItems: [DataItem]

    var body: some View {
        // Filter dataItems for this vehicle
        let vehicleDataItems = dataItems.filter { $0.vehicle == vehicle }
        // Group dataItems into trips
        let trips = groupDataItemsIntoTrips(dataItems: vehicleDataItems)

        List {
            if trips.isEmpty {
                Text("No trip data available for \(vehicle.name).")
                    .foregroundColor(.secondary)
            } else {
                Section(header: Text("Trips for \(vehicle.name)")) {
                    ForEach(trips.indices, id: \.self) { index in
                        let trip = trips[index]
                        if let startDate = trip.first?.time {
                            let length = calculateTripLength(trip: trip)
                            VStack(alignment: .leading) {
                                Text("Trip \(index + 1)")
                                    .font(.headline)
                                Text("Start Date: \(startDate, formatter: dateFormatter)")
                                Text("Length: \(String(format: "%.2f km", length / 1000))")
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .onAppear {
            print("Vehicle Detail View for: \(vehicle.name)")
            print("Number of trips: \(trips.count)")
        }
        .navigationTitle(vehicle.name)
    }

    // Functions to group dataItems into trips and calculate length
    func groupDataItemsIntoTrips(dataItems: [DataItem]) -> [[DataItem]] {
        var trips: [[DataItem]] = []
        var currentTrip: [DataItem] = []
        let timeThreshold: TimeInterval = 1 * 60  // 1 minute in seconds
        
        for (index, item) in dataItems.enumerated() {
            if index == 0 {
                currentTrip.append(item)
                continue
            }
            let previousItem = dataItems[index - 1]
            let timeDifference = item.time.timeIntervalSince(previousItem.time)
            if timeDifference > timeThreshold {
                // Time difference exceeds threshold, start a new trip
                trips.append(currentTrip)
                currentTrip = [item]
            } else {
                currentTrip.append(item)
            }
        }
        // Add the last trip
        if !currentTrip.isEmpty {
            trips.append(currentTrip)
        }
        return trips
    }
    
    func calculateTripLength(trip: [DataItem]) -> Double {
        var totalDistance: Double = 0
        for i in 1..<trip.count {
            let loc1 = CLLocation(latitude: trip[i - 1].lat, longitude: trip[i - 1].lon)
            let loc2 = CLLocation(latitude: trip[i].lat, longitude: trip[i].lon)
            totalDistance += loc1.distance(from: loc2)
        }
        return totalDistance  // in meters
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
