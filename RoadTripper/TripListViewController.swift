//
//  TripListViewController.swift
//  RoadTripper
//
//  Created by Gabe Guerrero on 10/29/19.
//  Copyright © 2019 Gabriel Guerrero. All rights reserved.
//

import UIKit

class TripListTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell") as! UITableViewCell
        cell.textLabel?.text = "Title Here"
        return cell
    }
}



