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
    @Query var dataItems: [DataItem] 
    @State private var showingVehicleSheet = false
    @State private var selectedVehicle: Vehicle?
    @Query private var vehicles: [Vehicle]

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
            if driving, let location = location, let vehicle = selectedVehicle {
                // Save a new DataItem when driving and location updates
                let newItem = DataItem(lon: location.longitude, lat: location.latitude, car: vehicle.type)
                context.insert(newItem)
                print("Saved DataItem at \(location.latitude), \(location.longitude) with vehicle \(vehicle.name)")
            } else if driving {
                // If no vehicle selected, prompt user
                print("No vehicle selected")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: {
                    if driving {
                        driving = false
                        print("Trip stopped")
                    } else {
                        if selectedVehicle == nil {
                            showingVehicleSheet = true
                        } else {
                            driving = true
                            print("Trip started")
                        }
                    }
                }) {
                    Text(driving ? "Stop" : "Start")
                }
                Spacer()
                Button(action: {
                    showingVehicleSheet = true
                }) {
                    Text(selectedVehicle?.name ?? "Select Vehicle")
                }
                .sheet(isPresented: $showingVehicleSheet) {
                    VehicleSelectionView(selectedVehicle: $selectedVehicle)
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
