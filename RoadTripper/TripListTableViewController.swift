//
//  TripListViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/29/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit

var trips = [Trip]()
var listCurrentIndex: IndexPath?
var defaultLocation: TripLocation?

let segueTripIdentifier = "segueTrip"

class TripListTableViewController: UITableViewController, UIAlertViewDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = trips[indexPath.row]
        listCurrentIndex = indexPath
        performSegue(withIdentifier: segueTripIdentifier, sender: selectedTrip)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell")!
        cell.textLabel?.text = trips[indexPath.row].nameOfTrip
        return cell
    }
    
    func showError(string: String) {
        let error = UIAlertController.init(title: "Error", message: string, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Not Cool", style: .default, handler: nil)
        error.addAction(doneAction)
        present(error, animated: true, completion: nil)        
    }
    
    @IBAction func newTripPressed(_ sender: Any) {
        let nameDialog = UIAlertController(title: "Trip Name", message: "Enter name of trip", preferredStyle: .alert)
        nameDialog.addTextField(configurationHandler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default) { (alert) in
            guard let name = nameDialog.textFields?.first?.text else { return }
            let newTrip = Trip(name: name, start: nil, dest: nil)
            trips.append(newTrip)
            listCurrentIndex = IndexPath(row: trips.endIndex - 1, section: 0)
            self.performSegue(withIdentifier: segueTripIdentifier, sender: newTrip)
        }
        nameDialog.addAction(doneAction)
        present(nameDialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == segueTripIdentifier) {
            guard let tripVC = segue.destination as? TripViewController else { showError(string: "Bad View Controller"); return }
            tripVC.trip = sender as? Trip
            tripVC.delegate = self
            tripVC.defaultLocation = defaultLocation
            if let defaultLocation = defaultLocation {
                tripVC.trip?.startLocation = defaultLocation
            }
        }
    }
}

extension TripListTableViewController: TripViewControllerDelegate {
    func valueChanged(trip: Trip) {
        guard let row = listCurrentIndex?.row else { showError(string: "Bad index in Trip list VC"); return }
        trips[row] = trip
    }
    
    func defaultLocationSet(tripLocation: TripLocation?) {
        defaultLocation = tripLocation
    }
}


