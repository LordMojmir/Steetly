//
//  ContentView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var driving: Bool = false
    @Environment(\.modelContext) private var context
    @Query(sort: \DataItem.time) var dataItems: [DataItem]
    @State private var showingShareSheet = false
    @State private var exportFileURL: URL?

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
                let tripCoordinates = removeNearbyDuplicateCoordinates(from: trips[index].map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) })
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
                Button(action: {
                    exportTripData()
                }) {
                    Text("Export")
                }
                Spacer()
            }
            .padding(.top)
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = exportFileURL {
                ShareSheet(activityItems: [fileURL])
            }
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
    
    // Function to remove nearby duplicate coordinates from an array
    func removeNearbyDuplicateCoordinates(from coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var uniqueCoordinates: [CLLocationCoordinate2D] = []
        guard !coordinates.isEmpty else { return uniqueCoordinates }
        
        uniqueCoordinates.append(coordinates[0])
        for coord in coordinates.dropFirst() {
            let lastCoord = uniqueCoordinates.last!
            let loc1 = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
            let loc2 = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = loc1.distance(from: loc2)
            if distance >= 10 {  // 10 meters threshold
                uniqueCoordinates.append(coord)
            }
        }
        return uniqueCoordinates
    }
    
    // Function to export trip data
    func exportTripData() {
        // Generate JSON data from the trips
        let trips = groupDataItemsIntoTrips(dataItems: dataItems)
        var exportTrips: [[String: Any]] = []
        
        for trip in trips {
            var tripData: [[String: Any]] = []
            for dataItem in trip {
                let itemData: [String: Any] = [
                    "id": dataItem.id,
                    "lon": dataItem.lon,
                    "lat": dataItem.lat,
                    "time": dataItem.time.iso8601String(),
                    "carType": dataItem.cartype
                ]
                tripData.append(itemData)
            }
            exportTrips.append(["trip": tripData])
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportTrips, options: [.prettyPrinted])
            
            // Save jsonData to a temporary file
            let tempDirectory = FileManager.default.temporaryDirectory
            let filename = "trip_data.json"
            let fileURL = tempDirectory.appendingPathComponent(filename)
            try jsonData.write(to: fileURL)
            
            // Set exportFileURL to the file URL
            self.exportFileURL = fileURL
            self.showingShareSheet = true
            
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

#Preview {
    ContentView()
}
