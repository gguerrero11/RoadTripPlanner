//
//  StopViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 11/3/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

protocol StopViewControllerDelegate {
    func updatedNotes(string: String)
}

class StopViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UITextView!
    
    var delegate: StopViewControllerDelegate?
    var previousStop: MKAnnotation?
    var mainStop: TripLocation!
    var stopName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = mainStop.name

        textView.delegate = self
        textView.text = mainStop.notes
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.gray.cgColor
            
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addAnnotation(mainStop)
        mapView.showAnnotations([mainStop], animated: true)
        
        if let prevStop = previousStop {
            mapView.addAnnotation(prevStop)
            mapView.showAnnotations([prevStop, mainStop], animated: true)
            showPolylineBetween(pointA: prevStop.coordinate, pointB: mainStop.coordinate)
        }
    }
    
    func showPolylineBetween(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pointA, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: pointB, addressDictionary: nil))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                DispatchQueue.main.async {
                    self.mapView.addOverlay(route.polyline)
                }
            }
        }
    }
}

extension StopViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

extension StopViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updatedNotes(string: textView.text)
    }
}
