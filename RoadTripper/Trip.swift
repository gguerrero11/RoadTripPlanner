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
    
    init(name: String, start: CLLocationCoordinate2D, notes: String?) {
        startLocation = Stop(name: name, location: start, notes: notes)
    }
    
    mutating func addDestination(name: String, dest: CLLocationCoordinate2D, notes: String?) {
        destination = Stop(name: name, location: dest, notes: notes)
    }
    
    mutating func addStop(name: String, location: CLLocationCoordinate2D, notes: String?) {
        stops?.append(Stop(name: name, location: location, notes: notes))
    }
}

class Stop: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var notes: String?
    
    init(name: String, location: CLLocationCoordinate2D, notes: String?) {
        self.name = name
        self.coordinate = location
        self.notes = notes
    }
}
