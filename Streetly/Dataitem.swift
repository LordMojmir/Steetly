//
//  DataItem.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import Foundation
import SwiftData

@Model
class DataItem: Identifiable {
    var id: String
    var lon: Double
    var lat: Double
    var time: Date
    var cartype: String

    init(lon: Double, lat: Double, car: String) {
        self.id = UUID().uuidString
        self.lon = lon
        self.lat = lat
        self.cartype = car
        self.time = Date()
    }
}
