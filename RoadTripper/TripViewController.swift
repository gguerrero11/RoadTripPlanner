//
//  TripViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stopsTableView: UITableView!
    
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!
    
    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trip = Trip(name: "Something", start: CLLocationCoordinate2DMake(37.33182, -122.03118), dest: CLLocationCoordinate2DMake(39.34182, -125.04118))
        
        guard let trip = trip else { return }
        startTextField.text = trip.startLocation.name
        destTextField.text = trip.destination?.name
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        let masterTrip = getMasterTrip(trip: trip)
        mapView.showsUserLocation = true
        mapView.addAnnotations(masterTrip)
        mapView.showAnnotations(masterTrip, animated: true)
    }
    
    func getMasterTrip(trip: Trip)->[MKAnnotation] {
        var result = [MKAnnotation]()
        result.append(trip.startLocation)
        if let stops = trip.stops { result.append(contentsOf: stops) }
        if let dest = trip.destination { result.append(dest) }
        return result
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip?.stops?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCell") as! UITableViewCell
        return cell
    }
    
    @IBAction func startBeginEditing(_ sender: Any) {
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func destinationBeginEditing(_ sender: Any) {
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSearchAddress") {
            if segue.destination is SearchAddressViewController {
            }
        }
    }
    

}
