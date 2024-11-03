//
//  ContentView.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let school = CLLocationCoordinate2D(latitude: 48.1857, longitude: 16.3567)
    @ObservedObject var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State public var driving: Bool = false
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Map(position: $camera) {
            if let userLocation = locationManager.currentLocation { 
                
            }
//            Marker("HTL Spengergasse", systemImage: "graduationcap.circle", coordinate: school).tint(.blue)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                if driving{
                    Button(action: {
                        driving = false
                        print("Start button pressed")
                    }) {
                        Text("Stop")
                    }
                }else{
                    Button(action: {
                        driving = true
                        print("Start button pressed")
                    }) {
                        Text("Start")
                    }
                }
                Spacer()
                Button(action: {
                    // has to be implemented
                    print("Change Car")
                }, label: {
                    Text("Change Car")
                })
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
        
        //    func addGeoItem(){
        //        let item = DataItem(47.0, 16.923)
        //
        //        context.insert(item)
        //    }
    }

    
    func addItem (){
        print("Item added")
        context.insert(DataItem(lon: 5.3, lat: 10.3, car: "Porsche 991 4s"))
    }
    func addItem (_ item : DataItem ){
        context.insert(item)
    }
}



#Preview {
    ContentView()
}
