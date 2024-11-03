//
//  ContentView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import SwiftUI
import MapKit
import SwiftData  // Imported SwiftData

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var driving: Bool = false
    @Environment(\.modelContext) private var context
    @Query(sort: \DataItem.time) var dataItems: [DataItem]

    var body: some View {
        // Group dataItems into trips
        let trips = groupDataItemsIntoTrips(dataItems: dataItems)
        
        Map(position: $camera) {
            if let userLocation = locationManager.currentLocation {
                // Optionally, display the user's current location
                UserAnnotation()
            }
            // Display polylines for each trip
            ForEach(trips.indices, id: \.self) { index in
                let tripCoordinates = trips[index].map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
                if tripCoordinates.count > 1 {
                    MapPolyline(coordinates: tripCoordinates)
                        .stroke(Color.blue, lineWidth: 5)
                }
            }
        }
        .onReceive(locationManager.$currentLocation) { location in
            if driving, let location = location {
                // Save a new DataItem when driving and location updates
                let newItem = DataItem(lon: location.longitude, lat: location.latitude, car: "Porsche 991 4s")
                context.insert(newItem)
                print("Saved DataItem at \(location.latitude), \(location.longitude)")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: {
                    driving.toggle()
                    print(driving ? "Start button pressed" : "Stop button pressed")
                }) {
                    Text(driving ? "Stop" : "Start")
                }
                Spacer()
                Button(action: {
                    // Implement car changing functionality here
                    print("Change Car")
                }) {
                    Text("Change Car")
                }
                Spacer()
            }
            .padding(.top)
            .background(.ultraThinMaterial)
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
        }
        .mapStyle(.standard(elevation: .realistic))
    }
    
    // Function to group dataItems into trips
    func groupDataItemsIntoTrips(dataItems: [DataItem]) -> [[DataItem]] {
        var trips: [[DataItem]] = []
        var currentTrip: [DataItem] = []
        let timeThreshold: TimeInterval = 1 * 60  // 1 minutes in seconds
        
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
}

#Preview {
    ContentView()
}
