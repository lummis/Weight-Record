//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let hks = HKHealthStore()
    let minWeight = 50.0
    let maxWeight = 250.0
    let helper = HealthKitHelper()
    var tableView: UITableView? = nil
    lazy var weightsAndDates: [ (weight: Double, date: Date) ]  = []
    var weightsAndDatesUpdated: Bool = false
    let delay = 0.2 // wait for the HK query to run
    
    func reloadTableAfterDelay() {
        perform(#selector(updateCells), with: nil, afterDelay: delay)
    }
    
    func updateCells() {
        if tableView != nil && !weightsAndDates.isEmpty {
            weightsAndDates.sort( by: {$0.date > $1.date} )
            tableView!.reloadData()
        } else { print("updateCells failed; either tableView is nil or weightsAndDates is empty") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ok = helper.authorizeHealthKit()
        print ("health kit helper authorized: \(ok)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        let yearStart = dateFormatter.date(from: "2017-Jan-01 00:00")!
        let now = Date()
        helper.getWeightsAndDates(fromDate: yearStart, toDate: now, vc: self)
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weightAndDateCell", for: indexPath) as! WeightAndDateCell
        cell.updateFields(withSample: weightsAndDates[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0, "fatal error: tableView asks for number of rows in section \(section)")
        return weightsAndDates.count
    }
    
}

