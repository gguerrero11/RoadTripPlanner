//
//  SearchAddressViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/31/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit
import MapKit

class SearchAddressViewController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: self)
        searchController?.searchResultsUpdater = self
        searchController?.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
    }
}

extension SearchAddressViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension SearchAddressViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // select address
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        return cell
    }
}


