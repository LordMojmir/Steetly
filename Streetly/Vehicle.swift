//
//  Vehicle.swift
//  Streetly
//
//  Created by Mojmír Horváth on 03.11.24.
//

import Foundation
import SwiftData

@Model
class Vehicle: Identifiable {
    var id: String
    var name: String
    var fuel_consumption: Double
    var type: String  // e.g., "Car", "Bike", "Porsche", "Skoda"

    init(name: String, type: String) {
        self.id = UUID().uuidString
        self.name = name
        self.type = type
        self.fuel_consumption = 10.0 // l/100km 
    }
}
