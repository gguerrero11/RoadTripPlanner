//
//  TripViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

protocol TripViewControllerDelegate {
    func valueChanged(trip: Trip)
    func defaultLocationSet(tripLocation: TripLocation?)
}

class TripViewController: UIViewController {
    
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var destTextField: UITextField!
    @IBOutlet weak var defaultSwitch: UISwitch!
    
    var trip: Trip?
    var selectedIndex: IndexPath?
    var isStartLocation: Bool?
    var tripPolylines = [MKPolyline]()
    var delegate: TripViewControllerDelegate?
    var addressSearchController: UISearchController?
    var defaultLocation: TripLocation?
    let locationManager = CLLocationManager()
    let segueSearchAddressIndentifier = "segueSearchAddress"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIcon.startAnimating()
        guard let trip = trip else { showError(string: "Really bad error. Passed in nil Trip"); return }
        title = trip.nameOfTrip
        
        defaultSwitch.isOn = (defaultLocation != nil)
        
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
        activityIcon.stopAnimating()
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
        clearCurrentPolylines()
        getMasterDirections(fromList: masterTrip)
    }
    
    func getMasterTrip()->[MKAnnotation] {
        var result = [MKAnnotation]()
        if let start = trip?.startLocation { result.append(start) }
        if let stops = trip?.stops { result.append(contentsOf: stops) }
        if let dest = trip?.destination { result.append(dest) }
        return result
    }
    
    func getMasterDirections(fromList: [MKAnnotation]) {
        guard fromList.count > 1 else { return }
        for x in 1..<fromList.count {
            let stop = fromList[x]
            let nextStop = fromList[x-1]
            collectTripBetween(pointA: stop.coordinate, pointB: nextStop.coordinate)
        }
    }
    
    func collectTripBetween(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D){
        DispatchQueue.main.async {
            self.activityIcon.startAnimating()
        }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pointA, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: pointB, addressDictionary: nil))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.tripPolylines.append(route.polyline)
            }
            self.drawPolylines()
        }
    }
    
    func drawPolylines() {
        DispatchQueue.main.async {
            self.tripPolylines.forEach { (polyline) in
                self.mapView.addOverlay(polyline)
            }
            self.activityIcon.stopAnimating()
        }
    }
    
    func clearCurrentPolylines() {
        mapView.removeOverlays(tripPolylines)
        tripPolylines = []
    }
    
    func showError(string: String) {
        let error = UIAlertController.init(title: "Error", message: string, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Not Cool", style: .default, handler: nil)
        error.addAction(doneAction)
        present(error, animated: true, completion: nil)
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        let uiSwitch = sender as! UISwitch
        delegate?.defaultLocationSet(tripLocation: (uiSwitch.isOn) ? trip?.startLocation : nil)
    }
    
    @IBAction func addStopPressed(_ sender: Any) {
        isStartLocation = nil
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func startBeginEditing(_ sender: Any) {
        if let startLocation = trip?.startLocation {
            mapView.removeAnnotation(startLocation)
        }
        startTextField.endEditing(true)
        isStartLocation = true
        performSegue(withIdentifier: "segueSearchAddress", sender: nil)
    }
    
    @IBAction func destinationBeginEditing(_ sender: Any) {
        if let destination = trip?.destination {
            mapView.removeAnnotation(destination)
        }
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
        
        if segue.identifier == "segueStop" {
            
            let stopVC = segue.destination as! StopViewController
            stopVC.delegate = self
            
            let stopTuple = sender as! (main: TripLocation, prev: MKAnnotation?)
            stopVC.previousStop = stopTuple.prev
            stopVC.mainStop = stopTuple.main
        }
    }
}

extension TripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let index = trip?.stops.firstIndex(of: view.annotation as! TripLocation) {
            stopsTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .bottom)
        } else {
            if let deselectIndex = stopsTableView.indexPathForSelectedRow {
                stopsTableView.deselectRow(at: deselectIndex, animated: true)
            }
        }
    }
}

extension TripViewController: StopViewControllerDelegate {
    func updatedNotes(string: String) {
        guard let selectedIndex = selectedIndex else { showError(string: "Bad index"); return }
        let selectedStop = trip?.stops[selectedIndex.row]
        selectedStop?.notes = string
        guard let trip = trip else { showError(string: "Bad trip can't return from updating notes"); return }
        delegate?.valueChanged(trip: trip)
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
            guard trip != nil else { showError(string: "Trip is nil when adding stop"); return }
            if !(trip!.stops.contains(tripLocation)) {
                trip!.addStop(name: tripLocation.name ?? "Unknown", location: tripLocation.coordinate, notes: nil)
                selectedIndex = IndexPath(row: trip!.stops.endIndex - 1, section: 0)
            }
            stopsTableView.reloadData()
        }
        
        if let trip = trip {
            delegate?.valueChanged(trip: trip)
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
        selectedIndex = indexPath
        let selectedStop = trip?.stops[indexPath.row]
        var previousStop: MKAnnotation?
        if (indexPath.row - 1) < 0 {
            if let start = trip?.startLocation {
                previousStop = start
            }
        } else {
            previousStop = trip?.stops[indexPath.row - 1]
        }
        performSegue(withIdentifier: "segueStop", sender: (main: selectedStop, prev: previousStop))
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


