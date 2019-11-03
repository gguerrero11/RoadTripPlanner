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
    
    var trip: Trip?
    var isStartLocation: Bool?
    var addressSearchController: UISearchController?
    let locationManager = CLLocationManager()
    let segueSearchAddressIndentifier = "segueSearchAddress"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let trip = trip else { showError(string: "Really bad error. Passed in nil Trip"); return }
        title = trip.nameOfTrip
        
        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        stopsTableView.sizeToFit()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        stopsTableView.delegate = self
        stopsTableView.dataSource = self
        
        refreshMap()
        getDirections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let trip = trip else { showError(string: "Really bad error. Passed in nil Trip"); return }
        startTextField.text = trip.startLocation?.name
        destTextField.text = trip.destination?.name
    }
    
    func refreshMap() {
        let masterTrip = getMasterTrip()
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
    
    func getMasterTrip()->[MKAnnotation] {
        var result = [MKAnnotation]()
        if let start = trip?.startLocation { result.append(start) }
        if let stops = trip?.stops { result.append(contentsOf: stops) }
        if let dest = trip?.destination { result.append(dest) }
        return result
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    @IBAction func addStopPressed(_ sender: Any) {
        isStartLocation = nil
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func startBeginEditing(_ sender: Any) {
        startTextField.endEditing(true)
        isStartLocation = true
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func destinationBeginEditing(_ sender: Any) {
        destTextField.endEditing(true)
        isStartLocation = false
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSearchAddress" {
            let searchVC = segue.destination as! SearchAddressViewController
            searchVC.mapView = mapView
            searchVC.delegate = self
        }
    }
}

extension TripViewController: SearchAddressViewControllerDelegate {
    func selectedTripLocation(tripLocation: TripLocation) {
        if let isStartLocation = isStartLocation {
            // Is a start or a destination
            if isStartLocation {
                trip?.startLocation = tripLocation
            } else {
                trip?.destination = tripLocation
            }
        } else {
            // Is a stop
            trip?.addStop(name: tripLocation.name ?? "Unknown", location: tripLocation.coordinate, notes: nil)
            stopsTableView.reloadData()
        }
        refreshMap()
    }
}

extension TripViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip?.stops.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCell")!
        if let stop = trip?.stops[indexPath.row] {
            cell.textLabel?.text = stop.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}


