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
    var startLocation: Stop
    var destination: Stop?
    var stops: [Stop]?
    
    init(name: String, start: MKMapPoint, notes: String?) {
        startLocation = Stop(name: name, location: start, notes: notes)
    }
    
    mutating func addDestination(name: String, dest: MKMapPoint, notes: String?) {
        destination = Stop(name: name, location: dest, notes: notes)
    }
    
    mutating func addStop(name: String, location: MKMapPoint, notes: String?) {
        stops?.append(Stop(name: name, location: location, notes: notes))
    }
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
