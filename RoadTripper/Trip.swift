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
    var nameOfTrip: String
    var startLocation: TripLocation?
    var destination: TripLocation?
    var stops = [TripLocation]()
    
    init(name: String, start: CLLocationCoordinate2D?, dest: CLLocationCoordinate2D?) {
        nameOfTrip = name
        if let start = start { startLocation = TripLocation(name: "nameStart", coordinate: start, notes: nil) }
        if let dest = dest { destination = TripLocation(name: "nameStop", coordinate: dest, notes: nil) }
    }
    
    mutating func addDestination(name: String, dest: CLLocationCoordinate2D, notes: String?) {
        destination = TripLocation(name: name, coordinate: dest, notes: notes)
    }
    
    mutating func addStop(name: String, location: CLLocationCoordinate2D, notes: String?) {
        stops.append(TripLocation(name: name, coordinate: location, notes: notes))
    }
}

class TripLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var notes: String?
    var name: String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, notes: String?) {
        self.coordinate = coordinate
        self.notes = notes
        self.name = name
    }
}
