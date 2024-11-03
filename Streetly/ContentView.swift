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
    let school = CLLocationCoordinate2D(latitude: 48.1857, longitude: 16.3567)
    @ObservedObject var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var driving: Bool = false
    @Environment(\.modelContext) private var context
    @Query var dataItems: [DataItem]  // Added @Query to fetch DataItems

    var body: some View {
        Map(position: $camera) {
            if let userLocation = locationManager.currentLocation {
                // You can add user location marker here if needed
            }
            // Display stored data points as markers on the map
            ForEach(dataItems) { item in
                Marker("", coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon))
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
}

#Preview {
    ContentView()
}
