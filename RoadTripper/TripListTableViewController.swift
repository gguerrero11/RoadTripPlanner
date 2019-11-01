//
//  TripListViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/29/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit

var trip = [Trip]()

class TripListTableViewController: UITableViewController, UIAlertViewDelegate {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell") as! UITableViewCell
        cell.textLabel?.text = trip[indexPath.row].nameOfTrip
        return cell
    }
    
    @IBAction func newTripPressed(_ sender: Any) {
        let nameDialog = UIAlertController(title: "Trip Name", message: "Enter name of trip", preferredStyle: .alert)
        nameDialog.addTextField(configurationHandler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default) { (alert) in
            guard let name = nameDialog.textFields?.first?.text else { return }
            self.performSegue(withIdentifier: "segueTripAdd", sender: Trip(name: name, start: nil, dest: nil))
        }
        nameDialog.addAction(doneAction)
        present(nameDialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueTripAdd") {
            
        }
    }
}



