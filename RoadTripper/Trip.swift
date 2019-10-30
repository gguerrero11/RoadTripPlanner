//
//  Trip.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/29/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import Foundation
import MapKit

struct Trip {
    var stops: [Stop]
}

struct Stop {
    var name: String
    var location: MKMapPoint
    var notes: String?
    
    init(name: String, location: MKMapPoint, notes: String?) {
        self.name = name
        self.location = location
        self.notes = notes
    }
}
