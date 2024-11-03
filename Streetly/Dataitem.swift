//
//  Dataitem.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import Foundation
import SwiftData

@Model
class DataItem: Identifiable{
    var id: String
    var lon: Float
    var lat: Float
    var time: Date
    var cartype: String
    
    
    init(lon: Float, lat: Float, car: String) {
        self.id = UUID().uuidString
        self.lon = lon
        self.lat = lat
        self.cartype = car
        self.time = Date()
    }
    
}
