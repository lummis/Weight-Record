//
//  WeightViewController.swift
//  BPW
//
//  Created by Robert Lummis on 7/5/17.
//  Copyright © 2017 ElectricTurkeySoftware. All rights reserved.
//

import UIKit
import HealthKit

class WeightVC: UIViewController, UITableViewDataSource, UITableViewDelegate, WeightAndDate {

    @IBOutlet weak var messageL: UILabel!
    
    let hks = HKHealthStore()
    let minWeight = 50.0
    let maxWeight = 250.0
    var helper: HealthKitHelper!
    var tableView: UITableView? = nil
    var weightsAndDates: [ (weight: Double, date: Date) ]  = []
    var messageText: String {
        get {
            return messageL.text ?? "messageText initial value"
        }
        set {
            messageL.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helper = HealthKitHelper(delegate: self)
        messageText = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm"
        let yearStart = dateFormatter.date(from: "2017-Jan-01 05:00")!
        let now = Date()
        helper.getWeightsAndDates(fromDate: yearStart, toDate: now)
    }
    
    func displayMessage(msg: String) {
        messageL.text = msg
    }
    
    func updateCells() {
        if tableView != nil && !weightsAndDates.isEmpty {
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

