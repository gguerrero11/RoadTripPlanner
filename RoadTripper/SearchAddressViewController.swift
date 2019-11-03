//
//  SearchAddressViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

var searchController: UISearchController?

protocol SearchAddressViewControllerDelegate {
    func selectedTripLocation(tripLocation: TripLocation)
}

class SearchAddressViewController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    var delegate: SearchAddressViewControllerDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: self)
        guard let searchController = searchController else { return }
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
}

extension SearchAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchController != nil else { return }
        guard let mapView = mapView,
            let searchBarText = searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            DispatchQueue.main.async {
                guard let response = response else { return }
                self.matchingItems = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchAddressViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selecteditem = matchingItems[indexPath.row]
        let coordinate = selecteditem.placemark.coordinate
        let tripLocation = TripLocation(name: selecteditem.placemark.name ?? String("\(coordinate.latitude), \(coordinate.longitude)"), coordinate: coordinate, notes: nil)
        delegate?.selectedTripLocation(tripLocation: tripLocation)
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "addressCell")
        let item = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = item.name
        return cell
    }
}


