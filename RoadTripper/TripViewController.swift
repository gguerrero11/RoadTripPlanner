//
//  TripViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stopsTableView: UITableView!
    
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!
    
    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let trip = trip else { showError(string: "Really bad error. Passed in nil Trip"); return }
        title = trip.nameOfTrip
        
        startTextField.text = trip.startLocation?.name
        destTextField.text = trip.destination?.name
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        let masterTrip = getMasterTrip(trip: trip)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addAnnotations(masterTrip)
        mapView.showAnnotations(masterTrip, animated: true)
        
        getDirections()
    }
    
    func showError(string: String) {
        let error = UIAlertController.init(title: "Error", message: string, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Not Cool", style: .default, handler: nil)
        error.addAction(doneAction)
        present(error, animated: true, completion: nil)
    }
    
    func getDirections() {
        guard let startCoordinate = trip?.startLocation?.coordinate else { return }
        guard let destCorrdinate = trip?.destination?.coordinate else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCorrdinate, addressDictionary: nil))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func getMasterTrip(trip: Trip)->[MKAnnotation] {
        var result = [MKAnnotation]()
        if let start = trip.startLocation { result.append(start) }
        if let stops = trip.stops { result.append(contentsOf: stops) }
        if let dest = trip.destination { result.append(dest) }
        return result
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = trip?.stops?.count ?? 0
        return result + 1 // last cell used to add stops
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var stopCount = trip?.stops?.count ?? 0
        stopCount += 1 // last cell used to add stops
        if indexPath.row == stopCount {
            return tableView.dequeueReusableCell(withIdentifier: "addStopCell") as! UITableViewCell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "stopCell") as! UITableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var stopCount = trip?.stops?.count ?? 0
        stopCount += 1 // last cell used to add stops
        if indexPath.row == stopCount {
            // add Stop
        }
    }
    
    @IBAction func startBeginEditing(_ sender: Any) {
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func destinationBeginEditing(_ sender: Any) {
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueSearchAddress") {
//            if segue.destination is SearchAddressViewController {
//            }
        }
    }
    
    
}


