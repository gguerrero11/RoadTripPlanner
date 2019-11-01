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
    var startLocation: Location
    var destination: Location?
    var stops: [Location]?
    
    init(name: String, start: CLLocationCoordinate2D, dest: CLLocationCoordinate2D?) {
        startLocation = Location(name: "nameStart", coordinate: start, notes: nil)
        if let dest = dest { destination = Location(name: "nameStop", coordinate: dest, notes: nil) }
    }
    
    mutating func addDestination(name: String, dest: CLLocationCoordinate2D, notes: String?) {
        destination = Location(name: name, coordinate: dest, notes: notes)
    }
    
    mutating func addStop(name: String, location: CLLocationCoordinate2D, notes: String?) {
        stops?.append(Location(name: name, coordinate: location, notes: notes))
    }
}

class Location: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String
    var notes: String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, notes: String?) {
        self.name = name
        self.coordinate = coordinate
        self.notes = notes
    }
}
