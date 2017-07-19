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
    var weightsAndDates: [ (weight: Double, date: Date) ]  = []
    var weightsAndDatesUpdated: Bool = false
    let delay: TimeInterval = 1.0 // wait for the HK query to run; probably a shorter delay is OK
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromHKDatabaseThenUpdateUIAfterDelay()
        perform(#selector(updateCells), with: nil, afterDelay: delay)
    }
    
    func getDataFromHKDatabaseThenUpdateUIAfterDelay() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        let yearStart = dateFormatter.date(from: "2017-Jan-01 05:00")!
        let now = Date()
        helper.readWeightsAndDates(fromDate: yearStart, toDate: now, vc: self)
    }
    
    func updateCells() {
        if tableView != nil && !weightsAndDates.isEmpty {
            weightsAndDates.sort( by: {$0.date > $1.date} )
            tableView!.reloadData()
        } else {
            fatalError("updateCells failed; tableView is nil or weightsAndDates is empty")
        }
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

