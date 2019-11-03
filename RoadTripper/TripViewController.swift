//
//  TripViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!
    
    var addressSearchController: UISearchController?
    let locationManager = CLLocationManager()
    let segueSearchAddressIndentifier = "segueSearchAddress"
    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let trip = trip else { showError(string: "Really bad error. Passed in nil Trip"); return }
        title = trip.nameOfTrip
        
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        startTextField.text = trip.startLocation?.name
        destTextField.text = trip.destination?.name
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        initializeMap(withTrip: trip)
        getDirections()
    }
    
    func initializeMap(withTrip trip: Trip) {
        let masterTrip = getMasterTrip(trip: trip)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addAnnotations(masterTrip)
        mapView.showAnnotations(masterTrip, animated: true)
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
    
    @IBAction func startBeginEditing(_ sender: Any) {
        startTextField.endEditing(true)
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func destinationBeginEditing(_ sender: Any) {
        destTextField.endEditing(true)
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSearchAddress" {
            let searchVC = segue.destination as! SearchAddressViewController
                searchVC.mapView = mapView
        }
    }
}

extension TripViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip?.stops?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "addStopCell")!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var stopCount = trip?.stops?.count ?? 0
        
    }
}

extension TripViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: (location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}


